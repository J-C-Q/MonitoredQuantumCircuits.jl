function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.CNOT,
    p1::Integer,
    p2::Integer)

    QC.apply!(backend.state, QC.sCNOT(p1,p2))
    return backend.state
end
