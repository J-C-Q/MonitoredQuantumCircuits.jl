function apply!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.Z,
    p::Integer;
    keep_result::Bool=false)

    QC.apply!(state, QC.sZ(p))
end
