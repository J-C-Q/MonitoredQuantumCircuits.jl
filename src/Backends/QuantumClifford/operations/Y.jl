function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.Y,
    p::Integer)

    QC.apply!(backend.state, QC.sY(p))
    return backend.state
end
