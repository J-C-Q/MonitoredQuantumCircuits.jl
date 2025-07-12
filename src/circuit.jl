# We need two circuit structures. One for interacivly creating the circuit. And one for efficently storing the circuit (optimized for iteration)

struct Position
    positions::Matrix{Int64}
    weights::StatsBase.Weights{Float64,Float64,Vector{Float64}}
    ancilla::Vector{Int64}
    function Position(position::Vararg{Integer})
        new(reshape([position...], (length(position), 1)), StatsBase.Weights([1.0]), zeros(Int64, 1))
    end
    function Position(positions::Matrix, probabilities::Vector)
        new(positions, StatsBase.Weights(probabilities), zeros(Int64, size(positions, 2)))
    end
end
struct Instruction
    operations::Vector{Int64}
    positions::Vector{Int64}
    weights::StatsBase.Weights{Float64,Float64,Vector{Float64}}
    function Instruction(operation::Integer, position::Integer)
        new([operation],[position], StatsBase.Weights([1.0]))
    end
    function Instruction(operations::Vector, positions::Vector, probabilities::Vector)
        new(operations,positions, StatsBase.Weights(probabilities))
    end
end

# CompiledCircuit optimized for interactive construction
"""
    Circuit{G<:Geometry}
A circuit optimized for interactive construction. The operations are stored in a vector to allow for efficient construction.
"""
struct Circuit{G<:Geometry}
    geometry::Geometry
    operations::Vector{Operation} #inefficient
    operationHashTable::Dict{UInt64,Int64}
    positions::Vector{Position}
    positionHashTable::Dict{UInt64,Int64}
    instructions::Vector{Instruction}
    instructionHashTable::Dict{UInt64,Int64}
    pointer::Vector{Int64}
    function Circuit(geometry::Geometry)
        G = typeof(geometry)
        operations = Operation[]
        operationHashTable = Dict{UInt64,Int64}()
        positions = Position[]
        positionHashTable = Dict{UInt64,Int64}()
        instructions = Instruction[]
        instructionHashTable = Dict{UInt64,Int64}()
        pointer = Int64[]
        new{G}(geometry, operations, operationHashTable, positions, positionHashTable, instructions, instructionHashTable, pointer)
    end
end

"""
    apply!(circuit::Circuit, operation::Operation, position::Integer)
Apply an operation to a position in the circuit.
"""
function apply!(circuit::Circuit, operation::Operation, position::Vararg{Integer})
    operationIndex = push!(circuit, operation)
    pos = Position(position...)
    positionIndex = push!(circuit, pos)
    instruction = Instruction(operationIndex, positionIndex)
    instructionIndex = push!(circuit, instruction)
    push!(circuit.pointer, instructionIndex)
end


function apply!(circuit::Circuit, operations::Vararg{Tuple{<:Operation,<:Real,Matrix{<:Integer},Vector{<:Real}}})
    sum([operation[2] for operation in operations]) ≈ 1.0 || throw(ArgumentError("Probabilities must add up to 1."))
    all([sum(operation[4]) for operation in operations] .≈ 1.0) || throw(ArgumentError("Probabilities must add up to 1."))

    operationIndecies = [push!(circuit, operation[1]) for operation in operations]
    positions = [Position(operation[3], operation[4]) for operation in operations]
    positionIndecies = [push!(circuit, pos) for pos in positions]
    probabilities = [operation[2] for operation in operations]
    instruction = Instruction(operationIndecies, positionIndecies, probabilities)
    instructionIndex = push!(circuit, instruction)
    push!(circuit.pointer, instructionIndex)
end

function apply!(circuit::Circuit, operations::Vector, probabilities::Vector, positions::Vector, positionProbabilities::Vector)
    sum(probabilities) ≈ 1.0 || throw(ArgumentError("Probabilities must add up to 1. Got sum($probabilities)=$(sum(probabilities))"))
    all([sum(prob) for prob in positionProbabilities] .≈ 1.0) || throw(ArgumentError("Probabilities must add up to 1."))

    operationIndecies = [push!(circuit, operation) for operation in operations]
    poses = [Position(position, prob) for (position, prob) in zip(positions, positionProbabilities)]
    positionIndecies = [push!(circuit, pos) for pos in poses]
    instruction = Instruction(operationIndecies, positionIndecies, probabilities)
    instructionIndex = push!(circuit, instruction)
    push!(circuit.pointer, instructionIndex)
end

"""
    apply!(circuit::Circuit, i::Integer)

Apply the i-th operation in the circuit again.
"""
function apply!(circuit::Circuit, i::Integer)
    push!(circuit.pointer, circuit.pointer[i])
end

"""
    apply!(circuit::Circuit, operation::RandomOperation)

Apply a [`RandomOperation`] to the circuit.
"""
function apply!(circuit::Circuit, operation::RandomOperation)
    apply!(circuit, operation.operations, operation.probabilities, operation.positions, operation.positionProbabilities)
end

"""
    apply!(circuit::Circuit, operation::DistributedOperation)

Apply a [`DistributedOperation`] to the circuit.
"""
function apply!(circuit::Circuit, operation::DistributedOperation)
    for (i, position) in enumerate(eachcol(operation.positions))
        apply!(circuit, [operation.operation, I()], [operation.probabilities[i], 1 - operation.probabilities[i]], [reshape(collect(position), length(position), 1), [1;;]], [[1.0], [1.0]])
    end
end









# CompiledCircuit optimized for interation (but static)
"""
    CompiledCircuit{Ops<:Tuple}
A circuit optimized for iteration. The operations are stored in a tuple. The operations are stored in a tuple to allow for efficient iteration.
"""
struct CompiledCircuit{Ops<:Tuple}
    operations::Ops
    positions::Vector{Position}
    instructions::Vector{Instruction}
    n_qubits::Int64
    n_ancilla::Int64
    pointer::Vector{Int64}
    qubits_map_compiled_to_geometry::Vector{Int64}
    qubits_map_geometry_to_compiled::Vector{Int64}
    n_measurements::Int64
    function CompiledCircuit(circuit::Circuit)
        operations = (circuit.operations...,)
        Ops = typeof(operations)
        positions = circuit.positions
        instructions = circuit.instructions
        pointer = circuit.pointer
        n_qubits = nQubits(circuit.geometry)
        used_positions = Set()
        for p in positions
            for i in eachcol(p.positions)
                for q in i
                    push!(used_positions, q)
                end
            end
        end
        used_qubits = sort!(collect(used_positions))

        qubits_map_geometry_to_compiled = zeros(Int64, n_qubits)
        qubits_map_compiled_to_geometry = zeros(Int64, length(used_qubits))
        for (i, q) in enumerate(used_qubits)
            qubits_map_geometry_to_compiled[q] = i
            qubits_map_compiled_to_geometry[i] = q
        end

        for pos in positions
            for i in eachindex(pos.positions)
                pos.positions[i] = qubits_map_geometry_to_compiled[pos.positions[i]]
            end
        end
        n_qubits = length(used_positions)
        # qubits_map_compiled_to_geometry = zeros(Int64, n_qubits)


        positions_accessed_by_ancilla = Position[]
        for i in instructions
            for j in eachindex(i.operations)
                if nAncilla(circuit.operations[i.operations[j]]) != 0
                    push!(positions_accessed_by_ancilla, circuit.positions[i.positions[j]])
                end
            end
        end
        ancilla = Dict{UInt64,Int64}()
        index = n_qubits + 1
        for pos in positions_accessed_by_ancilla
            for (i, p) in enumerate(eachcol(pos.positions))
                h = hash(sort(collect(p)))
                if !haskey(ancilla, h)
                    ancilla[h] = index
                    index += 1
                end
                pos.ancilla[i] = ancilla[h]
            end
        end
        nMeasurements = 0
        for p in pointer
            instruction = instructions[p]
            if typeof(instruction) <: MeasurementOperation
                nMeasurements += 1
            end
        end




        new{Ops}(operations, positions, instructions, n_qubits, maximum([a.second for a in ancilla]) - n_qubits, pointer, qubits_map_compiled_to_geometry, qubits_map_geometry_to_compiled, nMeasurements)
    end
end

"""
    compile(circuit::Circuit)
Compile the circuit. The function will return a CompiledCircuit object. The CompiledCircuit object is optimized for iteration and is not meant to be modified. The execute function only accepts CompiledCircuit objects.
"""
function compile(circuit::Circuit)
    c = CompiledCircuit(circuit)
    # precompile(getOperationByIndex, typeof(c), Int)
    return c
end

"""
    nQubits(circuit::CompiledCircuit)

Return the number of qubits in the compiled circuit. This can differ from the number of qubits in the original circuit, since unused qubits get deleated during compilation. Ancilla qubits are not included, use `nAncilla` to get the number of ancilla qubits.
"""
function nQubits(circuit::CompiledCircuit)
    return circuit.n_qubits
end

"""
    nAncilla(circuit::CompiledCircuit)

Return the number of ancilla qubits in the compiled circuit. An ancilla qubits gets added for every unique combination of position and operation.
"""
function nAncilla(circuit::CompiledCircuit)
    return circuit.n_ancilla
end



function Base.:(==)(pos1::Position,pos2::Position)
    return all(pos1.positions .== pos2.positions) && pos1.weights == pos2.weights
end
function Base.:(==)(ins1::Instruction,ins2::Instruction)
    return all(ins1.positions .== ins2.positions) && all(ins1.operations .== ins2.operations) && ins1.weights == ins2.weights
end
function Base.hash(position::Position)
    return hash((position.positions,position.weights))
end
function Base.hash(instruction::Instruction)
    return hash((instruction.operations,instruction.positions,instruction.weights))
end
function Base.in(operation::Operation, circuit::Circuit)
    return haskey(circuit.operationHashTable, hash(operation))
end
function Base.in(position::Position, circuit::Circuit)
    return haskey(circuit.positionHashTable, hash(position))
end
function Base.in(instruction::Instruction, circuit::Circuit)
    return haskey(circuit.instructionHashTable, hash(instruction))
end
function Base.getindex(circuit::Circuit, operation::Operation)
    return circuit.operationHashTable[hash(operation)]
end
function Base.getindex(circuit::Circuit, position::Position)
    return circuit.positionHashTable[hash(position)]
end
function Base.getindex(circuit::Circuit, instruction::Instruction)
    return circuit.instructionHashTable[hash(instruction)]
end
function Base.push!(circuit::Circuit, operation::Operation)
    if operation in circuit
        return circuit[operation]
    else
        push!(circuit.operations, operation)
        index = length(circuit.operations)
        circuit.operationHashTable[hash(operation)] = index
        return index
    end
    return 0
end
function Base.push!(circuit::Circuit, position::Position)
    if position in circuit
        return circuit[position]
    else
        push!(circuit.positions, position)
        index = length(circuit.positions)
        circuit.positionHashTable[hash(position)] = index
        return index
    end
    return 0
end
function Base.push!(circuit::Circuit, instruction::Instruction)
    if instruction in circuit
        return circuit[instruction]
    else
        push!(circuit.instructions, instruction)
        index = length(circuit.instructions)
        circuit.instructionHashTable[hash(instruction)] = index
        return index
    end
    return 0
end







"""
    execute(circuit::CompiledCircuit, backend::Backend)

Execute the circuit on the given backend. The backend must be a subclass of Backend. The function will return the result of the execution.
"""
function execute(::CompiledCircuit, backend::Backend)
    throw(ArgumentError("Backend $(typeof(backend)) not supported"))
end

function executeParallel end

function get_mpi_ref(input...)
    throw(ArgumentError("Load MPI.jl to use MPI"))
end

function Base.getindex(circuit::CompiledCircuit, i::Integer)
    instruction = circuit.instructions[circuit.pointer[i]]
    index = StatsBase.sample(instruction.weights)
    position = circuit.positions[instruction.positions[index]]
    posIndex = StatsBase.sample(position.weights)
    ancilla = position.ancilla[posIndex]
    return instruction.operations[index], @view(position.positions[:, posIndex]), ancilla
end
function Base.getindex(circuit::Circuit, i::Integer)
    instruction = circuit.instructions[circuit.pointer[i]]
    index = StatsBase.sample(instruction.weights)
    position = circuit.positions[instruction.positions[index]]
    posIndex = StatsBase.sample(position.weights)
    return circuit.operations[instruction.operations[index]], @view(position.positions[:, posIndex])
end

function sample(position::Position)
    index = StatsBase.sample(position.weights)
    return @view(position.positions[:, index])
end
function sample(instruction::Instruction)
    index = StatsBase.sample(instruction.weights)
    return index
end


"""
    depth(circuit::QuantumCircuit)

Return the depth of the circuit. The depth is the number of instructions in the circuit.
"""
function depth(circuit::CompiledCircuit)
    return length(circuit.pointer)
end
function depth(circuit::Circuit)
    return length(circuit.pointer)
end



function Base.show(io::IO, circuit::Circuit)
    if depth(circuit) < 10
        for i in 1:depth(circuit)
            instruction = circuit.instructions[circuit.pointer[i]]
            operationsIndeces = instruction.operations
            probs = instruction.weights
            for (prob, j) in zip(probs, operationsIndeces)
                operation = circuit.operations[j]
                print(io, prob * 100, "%: ", operation, " ")
            end
            println()
        end
    else
        for i in 1:5
            instruction = circuit.instructions[circuit.pointer[i]]
            operationsIndeces = instruction.operations
            probs = instruction.weights
            for (prob, j) in zip(probs, operationsIndeces)
                operation = circuit.operations[j]
                print(io, prob * 100, "%: ", operation, " ")
            end
            println()
        end
        println("⋮")
        for i in depth(circuit)-5:depth(circuit)
            instruction = circuit.instructions[circuit.pointer[i]]
            operationsIndeces = instruction.operations
            probs = instruction.weights
            for (prob, j) in zip(probs, operationsIndeces)
                operation = circuit.operations[j]
                print(io, prob * 100, "%: ", operation, " ")
            end
            println()
        end
    end

end

function Base.show(io::IO, circuit::CompiledCircuit)
    println("Compiled circuit with $(circuit.n_qubits) system qubits and $(circuit.n_ancilla) ancilla qubits.")
end

@generated function getOperation(circuit::CompiledCircuit, ::Val{i}) where {i}
    return :(circuit.operations[$i])
end

@generated function getOperationByIndex(circuit::CompiledCircuit{Ops}, i::Integer) where {Ops}
    n = length(Ops.parameters)
    branches = Vector{Expr}(undef, n + 1)
    for j in 1:n
        branches[j] = quote
            if i == $(j)
                return getOperation(circuit, Val($(j)))
            end
        end
    end
    branches[n+1] = :(error("Index out of bounds: ", i))
    return Expr(:block, branches...)
end
