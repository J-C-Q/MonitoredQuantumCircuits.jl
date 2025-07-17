function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.H,
    p::Integer)

    QC.apply!(backend.state, QC.sHadamard(p))
    return backend.state
end
