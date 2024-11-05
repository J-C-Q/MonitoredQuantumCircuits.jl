struct TableauSimulator <: MonitoredQuantumCircuits.Simulator
end

struct PauliFrameSimulator <: MonitoredQuantumCircuits.Simulator
end

struct GPUPauliFrameSimulator <: MonitoredQuantumCircuits.Simulator
end


function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, ::TableauSimulator; verbose::Bool=true, initial_state=QC.MixedDestabilizer(zero(QC.Stabilizer, MonitoredQuantumCircuits.nQubits(circuit.lattice))))
    state = QC.Register(initial_state, MonitoredQuantumCircuits.nMeasurements(circuit))
    qc = MonitoredQuantumCircuits.translate(Circuit, circuit)
    # println(QC.nqubits(initial_state))
    for operation in qc.operations
        QC.apply!(state, operation)
    end
    verbose && println("✓")
    return state
end

function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, ::PauliFrameSimulator; verbose::Bool=true, shots=1024, initial_state=QC.MixedDestabilizer(zero(QC.Stabilizer, MonitoredQuantumCircuits.nQubits(circuit.lattice))))

    # state = QC.Register(initial_state, MonitoredQuantumCircuits.nMeasurements(circuit))

    qc = MonitoredQuantumCircuits.translate(Circuit, circuit)
    # frames = QC.pftrajectories(state, qc.operations; trajectories=shots)
    frame = QC.PauliFrame(shots, MonitoredQuantumCircuits.nQubits(circuit.lattice), MonitoredQuantumCircuits.nMeasurements(circuit))
    frames = QC.pftrajectories(frame, qc.operations)
    verbose && println("✓")
    return frames
end

function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, ::GPUPauliFrameSimulator; verbose::Bool=true, shots=1024, initial_state=QC.MixedDestabilizer(zero(QC.Stabilizer, MonitoredQuantumCircuits.nQubits(circuit.lattice))))

    # state = QC.Register(initial_state, MonitoredQuantumCircuits.nMeasurements(circuit))

    qc = MonitoredQuantumCircuits.translate(Circuit, circuit)
    pf_gpu = to_gpu(PauliFrame(shots, MonitoredQuantumCircuits.nQubits(circuit.lattice), MonitoredQuantumCircuits.nMeasurements(circuit)))
    frames = QC.pftrajectories(pf_gpu, qc.operations)
    # frames = QC.pftrajectories(state, QC.to_gpu(qc.operations); trajectories=shots)
    verbose && println("✓")
    return frames
end
