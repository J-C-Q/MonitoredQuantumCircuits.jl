"""
    TableauSimulator(qubits::Integer; mixed=true, basis=:Z)
    TableauSimulator(initial_state::QuantumClifford.MixedDestabilizer)

A QuantumClifford stabilizer simulator.
"""
struct TableauSimulator <: MonitoredQuantumCircuits.Simulator
    initial_state::QC.MixedDestabilizer
    pauli_operator::QC.PauliOperator
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


function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, simulator::TableauSimulator; keep_result=false)
    state = simulator.initial_state

    for i in eachindex(1:MonitoredQuantumCircuits.depth(circuit))
        apply!(state, simulator, circuit.operations[i], circuit.positions[i]...; keep_result)
    end

    return state
end









# function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, ::PauliFrameSimulator; verbose::Bool=true, shots=1024, initial_state=QC.MixedDestabilizer(zero(QC.Stabilizer, MonitoredQuantumCircuits.nQubits(circuit.lattice))))

#     # state = QC.Register(initial_state, MonitoredQuantumCircuits.nMeasurements(circuit))

#     qc = MonitoredQuantumCircuits.translate(Circuit, circuit)
#     # frames = QC.pftrajectories(state, qc.operations; trajectories=shots)
#     frame = QC.PauliFrame(shots, MonitoredQuantumCircuits.nQubits(circuit.lattice), MonitoredQuantumCircuits.nMeasurements(circuit))
#     frames = QC.pftrajectories(frame, qc.operations)
#     verbose && println("✓")
#     return frames
# end

# function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, ::GPUPauliFrameSimulator; verbose::Bool=true, shots=1024, initial_state=QC.MixedDestabilizer(zero(QC.Stabilizer, MonitoredQuantumCircuits.nQubits(circuit.lattice))))

#     # state = QC.Register(initial_state, MonitoredQuantumCircuits.nMeasurements(circuit))

#     qc = MonitoredQuantumCircuits.translate(Circuit, circuit)
#     pf_gpu = QC.to_gpu(QC.PauliFrame(shots, MonitoredQuantumCircuits.nQubits(circuit.lattice), MonitoredQuantumCircuits.nMeasurements(circuit)))
#     frames = QC.pftrajectories(pf_gpu, qc.operations)
#     # frames = QC.pftrajectories(state, QC.to_gpu(qc.operations); trajectories=shots)
#     verbose && println("✓")
#     return frames
# end


# function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.RandomCircuit, ::TableauSimulator; verbose::Bool=true, initial_state=QC.MixedDestabilizer(zero(QC.Stabilizer, MonitoredQuantumCircuits.nQubits(circuit.geometry))))

#     state = QC.Register(initial_state, circuit.depth)

#     measurementCount = 0

#     nqubits = MonitoredQuantumCircuits.nQubits(circuit.lattice)
#     for _ in 1:circuit.depth
#         i = sample(1:length(circuit.operations), StatsBase.Weights(circuit.probabilities))
#         operation = circuit.operations[i]
#         pos = rand(circuit.operationPositions[i])

#         if typeof(operation) <: MonitoredQuantumCircuits.MeasurementOperation
#             measurementCount += 1
#         end
#         apply!(state, operation, nqubits, measurementCount, pos...)
#     end

#     verbose && println("✓")
#     return state

# end
