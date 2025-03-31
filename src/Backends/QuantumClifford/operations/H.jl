function apply!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.H,
    p::Integer;
    keep_result::Bool=false)

    QC.apply!(state, QC.sHadamard(p))
end
