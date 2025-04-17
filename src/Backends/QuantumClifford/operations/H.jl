function apply!(
    register::QC.Register,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.H,
    p)

    QC.apply!(register, QC.sHadamard(p))
end
