struct MonteCarloSimulator <: MonitoredQuantumCircuits.Simulator
end
function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, ::MonteCarloSimulator; shots=1024, verbose::Bool=true)
    initial_state = QC.MixedDestabilizer(QC.Stabilizer(one(QC.Tableau, 6 * MonitoredQuantumCircuits.nQubits(circuit.lattice); basis=:X)))
    state = QC.Register(initial_state, falses(length(circuit.lattice)))
    qc = MonitoredQuantumCircuits.translate(Circuit, circuit)

    for operation in qc.operations
        QC.apply!(state, operation)
    end
    verbose && println("✓")
    return state
end
