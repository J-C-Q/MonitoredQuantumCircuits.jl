function apply!(
    register::QC.Register,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.Z,
    p)

    QC.apply!(register, QC.sZ(p[1]))
end
