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
function setInitialState(sim::TableauSimulator, state::QC.MixedDestabilizer)
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

function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.CompiledCircuit, simulator::TableauSimulator; keep_result::Bool=false)
    simulator = deepcopy(simulator)
    state = simulator.initial_state
    for i in 1:MonitoredQuantumCircuits.depth(circuit)
        operation, position, _ = circuit[i]
        apply!(state, simulator, MonitoredQuantumCircuits.getOperationByIndex(circuit, operation), position; keep_result)
    end
    return state
end

function MonitoredQuantumCircuits.executeParallel(circuit::MonitoredQuantumCircuits.CompiledCircuit, simulator::TableauSimulator; keep_result::Bool=false, samples=1)
    MPI, rank, size = MonitoredQuantumCircuits.get_mpi_ref()
    Threads.@threads for i in 1:samples÷size
        MonitoredQuantumCircuits.execute(circuit, simulator; keep_result)

    end
end
