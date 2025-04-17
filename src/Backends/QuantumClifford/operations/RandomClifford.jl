function apply!(
    register::QC.Register,
    ::TableauSimulator,
    R::MonitoredQuantumCircuits.RandomClifford,
    p)

    QC.apply!(register, QC.random_clifford(R.nqubits), p...)
end
