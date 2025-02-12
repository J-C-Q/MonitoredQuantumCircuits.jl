function apply!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.Y,
    p::Integer;
    keep_result::Bool=false)

    QC.apply!(state, QC.sY(p))
end
