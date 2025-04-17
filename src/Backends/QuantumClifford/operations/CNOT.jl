function apply!(
    register::QC.Register,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.CNOT,
    p)

    QC.apply!(register, QC.sCNOT(register, p[1], p[2]))
end
