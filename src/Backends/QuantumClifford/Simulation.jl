struct TableauSimulator <: MonitoredQuantumCircuits.Simulator
end
function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, ::TableauSimulator; shots=1024, verbose::Bool=true, initial_state=QC.MixedDestabilizer(zero(QC.Stabilizer, MonitoredQuantumCircuits.nQubits(circuit.lattice))))
    state = QC.Register(initial_state, falses(length(circuit.lattice)))
    qc = MonitoredQuantumCircuits.translate(Circuit, circuit)
    # println(QC.nqubits(initial_state))
    for operation in qc.operations
        QC.apply!(state, operation)
    end
    verbose && println("✓")
    return state
end
