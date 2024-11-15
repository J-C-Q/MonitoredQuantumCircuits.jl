struct TableauSimulator <: MonitoredQuantumCircuits.Simulator
end
using BenchmarkTools
# struct GPUTableauSimulator <: MonitoredQuantumCircuits.Simulator

struct PauliFrameSimulator <: MonitoredQuantumCircuits.Simulator
end

struct GPUPauliFrameSimulator <: MonitoredQuantumCircuits.Simulator
end


function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, ::TableauSimulator; verbose::Bool=true, initial_state=QC.MixedDestabilizer(zero(QC.Stabilizer, MonitoredQuantumCircuits.nQubits(circuit.lattice))))
    state = QC.Register(initial_state, MonitoredQuantumCircuits.nMeasurements(circuit))
    # qc = MonitoredQuantumCircuits.translate(Circuit, circuit)
    # println(QC.nqubits(initial_state))
    # for operation in qc.operations
    #     QC.apply!(state, operation)
    # end
    measurementCount = 0
    # for (i, ptr) in enumerate(circuit.operationPointers)
    #     if typeof(circuit.operations[ptr]) <: MonitoredQuantumCircuits.MeasurementOperation
    #         measurementCount += 1
    #         QC.apply!(state, apply!(circuit.operations[ptr], measurementCount, MonitoredQuantumCircuits.nQubits(circuit.lattice), circuit.operationPositions[i]...))
    #     else
    #         QC.apply!(state, apply!(circuit.operations[ptr], circuit.operationPositions[i]...))
    #     end
    # end
    nqubits = MonitoredQuantumCircuits.nQubits(circuit.lattice)
    for (i, ptr) in enumerate(circuit.operationPointers)
        if typeof(circuit.operations[ptr]) <: MonitoredQuantumCircuits.MeasurementOperation
            measurementCount += 1
        end
        apply!(state, circuit.operations[ptr], nqubits, measurementCount, circuit.operationPositions[i]...)
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
    pf_gpu = QC.to_gpu(QC.PauliFrame(shots, MonitoredQuantumCircuits.nQubits(circuit.lattice), MonitoredQuantumCircuits.nMeasurements(circuit)))
    frames = QC.pftrajectories(pf_gpu, qc.operations)
    # frames = QC.pftrajectories(state, QC.to_gpu(qc.operations); trajectories=shots)
    verbose && println("✓")
    return frames
end
