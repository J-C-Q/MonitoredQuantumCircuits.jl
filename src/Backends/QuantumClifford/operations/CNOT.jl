function apply!(
    register::QC.Register,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.CNOT,
    p)

    QC.apply!(register, QC.sCNOT(register, p[1], p[2]))
end

function apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.CNOT,
    p1::Integer,p2::Integer)

    QC.apply!(backend.register, QC.sCNOT(backend.register, p1, p2))
end

function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.CNOT,
    p1::Integer,
    p2::Integer)

    QC.apply!(backend.state, QC.sCNOT(p1,p2))
    return backend.state
end
