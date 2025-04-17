function apply!(
    register::QC.Register,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.Y,
    p)

    QC.apply!(register, QC.sY(p[1]))
end
