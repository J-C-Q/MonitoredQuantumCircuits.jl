struct TableauSimulator <: MonitoredQuantumCircuits.Simulator
end
function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, ::TableauSimulator; verbose::Bool=true, initial_state=QC.MixedDestabilizer(zero(QC.Stabilizer, MonitoredQuantumCircuits.nQubits(circuit.lattice))))
    state = QC.Register(initial_state, MonitoredQuantumCircuits.nMeasurements(circuit))
    qc = MonitoredQuantumCircuits.translate(Circuit, circuit)
    println(qc.operations)
    # println(QC.nqubits(initial_state))
    for operation in qc.operations
        QC.apply!(state, operation)
    end
    verbose && println("✓")
    return state
end
