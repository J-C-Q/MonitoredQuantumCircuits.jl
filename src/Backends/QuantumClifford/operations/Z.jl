function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.Z,
    p::Integer)

    QC.apply!(backend.state, QC.sZ(p))
    return backend.state
end
