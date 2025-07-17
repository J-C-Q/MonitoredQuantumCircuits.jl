function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.X,
    p::Integer)

    QC.apply!(backend.state, QC.sX(p))
    return backend.state
end
