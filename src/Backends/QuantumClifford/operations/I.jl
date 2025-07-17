function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.I,
    p::Integer)

    QC.apply!(backend.state, QC.sId1(p))
    return backend.state
end
