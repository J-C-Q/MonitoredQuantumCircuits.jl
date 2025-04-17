function apply!(
    register::QC.Register,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.I,
    p)

    QC.apply!(register, QC.sId1(p[1]))
end
