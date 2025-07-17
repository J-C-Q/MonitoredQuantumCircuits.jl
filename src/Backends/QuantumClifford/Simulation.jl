"""
    TableauSimulator(qubits::Integer; mixed=true, basis=:Z)
    TableauSimulator(initial_state::QuantumClifford.MixedDestabilizer)

A QuantumClifford stabilizer simulator.
"""
struct TableauSimulator <: MonitoredQuantumCircuits.Simulator
    state::QC.MixedDestabilizer{QC.Tableau{Vector{UInt8},Matrix{UInt64}}}
    operator::QC.PauliOperator{Array{UInt8,0},Vector{UInt64}}
    measurements::BitVector
    function TableauSimulator(qubits::Integer; mixed=true, basis=:Z)
        if mixed
            state = QC.MixedDestabilizer(zero(QC.Stabilizer, qubits))
            operator = QC.zero(QC.PauliOperator, qubits)
            new(state, operator, falses(0))
        else
            state = QC.MixedDestabilizer(one(QC.Stabilizer, qubits; basis))
            operator = QC.zero(QC.PauliOperator, qubits)
            new(state, operator, falses(0))
        end
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



function MonitoredQuantumCircuits.execute(simulator::TableauSimulator)
    return simulator.state, simulator.measurements
end

function MonitoredQuantumCircuits.executeParallel(circuit::MonitoredQuantumCircuits.CompiledCircuit, simulator::TableauSimulator; samples=1)
    MPI, rank, size = MonitoredQuantumCircuits.get_mpi_ref()
    Threads.@threads for i in 1:samples÷size
        MonitoredQuantumCircuits.execute(circuit, simulator)

    end
end
