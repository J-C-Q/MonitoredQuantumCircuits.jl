function apply!(
    register::QC.Register,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.X,
    p)

    QC.apply!(register, QC.sX(p[1]))
end
