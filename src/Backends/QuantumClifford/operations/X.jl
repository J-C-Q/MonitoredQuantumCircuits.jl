function apply!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.X,
    p::Integer;
    keep_result::Bool=false)

    QC.apply!(state, QC.sX(p))
end
