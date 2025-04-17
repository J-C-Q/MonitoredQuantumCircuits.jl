"""
    TableauSimulator(qubits::Integer; mixed=true, basis=:Z)
    TableauSimulator(initial_state::QuantumClifford.MixedDestabilizer)

A QuantumClifford stabilizer simulator.
"""
struct TableauSimulator <: MonitoredQuantumCircuits.Simulator
    initial_state::QC.MixedDestabilizer{QC.Tableau{Vector{UInt8},Matrix{UInt64}}}
    pauli_operator::QC.PauliOperator{Array{UInt8,0},Vector{UInt64}}
    function TableauSimulator(qubits::Integer; mixed=true, basis=:Z)
        if mixed
            new(QC.MixedDestabilizer(zero(QC.Stabilizer, qubits)), QC.zero(QC.PauliOperator, qubits))
        else
            new(QC.MixedDestabilizer(one(QC.Stabilizer, qubits; basis)), QC.zero(QC.PauliOperator, qubits))
        end
    end
    function TableauSimulator(initial_state::QC.MixedDestabilizer)
        new(initial_state, QC.zero(QC.PauliOperator, initial_state.tab.nqubits))
    end
end
function setInitialState!(sim::TableauSimulator, state::QC.MixedDestabilizer)
    sim.initial_state.tab.phases .= state.tab.phases
    sim.initial_state.tab.xzs .= state.tab.xzs
    sim.initial_state.rank = state.rank
end

"""
    PauliFrameSimulator()

A QuantumClifford stabilizer Pauli frame simulator.
"""
struct PauliFrameSimulator <: MonitoredQuantumCircuits.Simulator
end

"""
    GPUPauliFrameSimulator()

A QuantumClifford stabilizer Pauli frame simulator that runs on the GPU.
"""
struct GPUPauliFrameSimulator <: MonitoredQuantumCircuits.Simulator
end

struct QuantumCliffordCode
    code::Function
end

function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.CompiledCircuit, simulator::TableauSimulator)

    # simulator = deepcopy(simulator)
    state = simulator.initial_state
    register = QC.Register(state)
    for i in 1:MonitoredQuantumCircuits.depth(circuit)
        operation, position, _ = circuit[i]
        apply!(register, simulator, MonitoredQuantumCircuits.getOperationByIndex(circuit, operation), position)
    end
    return register
end

function MonitoredQuantumCircuits.execute(code::QuantumCliffordCode)
    return code.code()
end
"""
    fast_execute(circuit::MonitoredQuantumCircuits.CompiledCircuit, simulator::TableauSimulator)

This function executes the circuit using the TableauSimulator. It generates native QuantumClifford code which then gets executed. This makes executing the same circuit many times much faster and more efficient.
"""
function native_codeV1(circuit::MonitoredQuantumCircuits.CompiledCircuit, simulator::TableauSimulator)
    simulator = deepcopy(simulator)
    state = simulator.initial_state
    register = QC.Register(state)
    exprArray = []
    # push!(exprArray, :(circuit = $circuit))
    push!(exprArray, :(simulator = $simulator))
    push!(exprArray, :(state = copy($state)))
    push!(exprArray, :(register = QuantumClifford.QC.Register(state)))
    positions = circuit.positions
    # push!(exprArray, :(QuantumClifford.QC.setInitialState(register.stab, state)))


    # Collect the expressions for each operation in the circuit
    operation_expressions = Vector{Function}(undef, length(circuit.operations))
    for (i, operation) in enumerate(circuit.operations)
        expr = expr_apply!(operation)
        operation_expressions[i] = eval(quote
            (register, p, simulator) -> begin
                $(expr)
            end
        end)
    end
    push!(exprArray, :(operation_expressions = $operation_expressions))


    instruction_functions = Vector{Function}(undef, length(circuit.instructions))
    for (i, instruction) in enumerate(circuit.instructions)
        instruction_functions[i] = eval(quote
            (register, operation_expressions, simulator) -> begin
                index = MonitoredQuantumCircuits.sample($instruction)
                r = rand()

                operation_index = $(instruction.operations)[index]
                position = $(positions)[$(instruction.positions)[index]]
                p = MonitoredQuantumCircuits.sample(position)
                operation_expressions[operation_index](register, p, simulator)
            end
        end)
    end

    push!(exprArray, :(instruction_functions = $instruction_functions))


    push!(exprArray, quote
        for i in $(circuit.pointer)
            instruction_functions[i](register, operation_expressions, simulator)
        end
    end)

    func = quote
        function native_execute()
            $(Expr(:block, exprArray...))
            return register
        end
    end
    return QuantumCliffordCode(eval(func))
end

function native_code(circuit::MonitoredQuantumCircuits.CompiledCircuit, simulator::TableauSimulator)
    simulator = deepcopy(simulator)
    state = simulator.initial_state
    register = QC.Register(state)
    exprArray = []
    # push!(exprArray, :(circuit = $circuit))
    push!(exprArray, :(simulator = $simulator))
    push!(exprArray, :(state = copy($state)))
    push!(exprArray, :(register = QuantumClifford.QC.Register(state)))
    positions = circuit.positions
    # push!(exprArray, :(QuantumClifford.QC.setInitialState(register.stab, state)))


    # Collect the expressions for each operation in the circuit
    operation_expressions = Vector{Expr}(undef, length(circuit.operations))
    for (i, operation) in enumerate(circuit.operations)
        expr = expr_apply!(operation)
        operation_expressions[i] = expr
    end


    instruction_expressions = Vector{Expr}(undef, length(circuit.instructions))
    for (i, instruction) in enumerate(circuit.instructions)
        expressions = Expr[]
        push!(expressions, :(r = rand()))

        nested_if_expr = nothing
        for j in reverse(1:length(instruction.weights))
            # Create condition
            cond = :(r < $(sum(@view(instruction.weights[1:j]))))
            expr = quote
                p = MonitoredQuantumCircuits.sample($(circuit.positions[instruction.positions[j]]))
                $(operation_expressions[instruction.operations[j]])
            end
            # For the innermost branch, we use 'nothing' as a fallback.
            if nested_if_expr === nothing
                nested_if_expr = Expr(:if, cond, expr, nothing)
            else
                nested_if_expr = Expr(:if, cond, expr, nested_if_expr)
            end
        end
        push!(expressions, nested_if_expr)
        instruction_expressions[i] = Expr(:block, expressions...)
    end

    nested_if_expr = nothing
    for j in reverse(1:length(instruction_expressions))
        # Create condition: (my_i == i)
        cond = :(i == $(j))

        # For the innermost branch, we use 'nothing' as a fallback.
        if nested_if_expr === nothing
            nested_if_expr = Expr(:if, cond, instruction_expressions[j], nothing)
        else
            nested_if_expr = Expr(:if, cond, instruction_expressions[j], nested_if_expr)
        end
    end

    push!(exprArray, quote
        for i in $(circuit.pointer)
            $nested_if_expr
        end
    end)

    func = quote
        () -> begin
            $(Expr(:block, exprArray...))
            return register
        end
    end
    return QuantumCliffordCode(eval(func))
end

function native_codeV0(circuit::MonitoredQuantumCircuits.CompiledCircuit, simulator::TableauSimulator)
    simulator = deepcopy(simulator)
    state = simulator.initial_state
    register = QC.Register(state)
    exprArray = []
    push!(exprArray, :(circuit = $circuit))
    push!(exprArray, :(simulator = $simulator))
    push!(exprArray, :(state = copy($state)))
    push!(exprArray, :(register = QuantumClifford.QC.Register(state)))
    # push!(exprArray, :(QuantumClifford.QC.setInitialState(register.stab, state)))


    instruction_exprs = []
    for (index, instruction) in enumerate(circuit.instructions)

        ex = []

        push!(ex, :(r = rand()))
        for j in eachindex(instruction.weights)
            gate_expr = expr_apply!(circuit.operations[instruction.operations[j]])
            weight = sum(instruction.weights[1:j])
            position = circuit.positions[instruction.positions[j]]
            expr_block = quote
                if r < $weight
                    p = MonitoredQuantumCircuits.sample($position)
                    $(gate_expr)
                end
            end
            push!(ex, expr_block)
        end
        push!(instruction_exprs, Expr(:block, ex...))
    end

    nested_if_expr = nothing
    for i in reverse(1:length(instruction_exprs))
        # Create condition: (my_i == i)
        cond = :(my_i == $(i))

        # For the innermost branch, we use 'nothing' as a fallback.
        if nested_if_expr === nothing
            nested_if_expr = Expr(:if, cond, instruction_exprs[i], nothing)
        else
            nested_if_expr = Expr(:if, cond, instruction_exprs[i], nested_if_expr)
        end
    end



    expr_block = quote
        for i in $(circuit.pointer)
            my_i = i
            # Execute the nested if-else structure
            $(nested_if_expr)
        end
    end
    push!(exprArray, expr_block)

    func = quote
        () -> begin
            $(Expr(:block, exprArray...))
            return register
        end
    end
    return QuantumCliffordCode(eval(func))
end


function MonitoredQuantumCircuits.executeParallel(circuit::MonitoredQuantumCircuits.CompiledCircuit, simulator::TableauSimulator; samples=1)
    MPI, rank, size = MonitoredQuantumCircuits.get_mpi_ref()
    Threads.@threads for i in 1:samples÷size
        MonitoredQuantumCircuits.execute(circuit, simulator)

    end
end
