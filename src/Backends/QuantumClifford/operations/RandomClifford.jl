function apply!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    R::MonitoredQuantumCircuits.RandomClifford,
    p;
    keep_result::Bool=false)

    QC.apply!(state, QC.random_clifford(R.nqubits), p...)
end
