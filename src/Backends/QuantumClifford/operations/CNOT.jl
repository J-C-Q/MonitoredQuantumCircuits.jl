function apply!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.H,
    p1::Integer,
    p2::Integer;
    keep_result::Bool=false)

    QC.apply!(state, QC.sCNOT(state, p1, p2))
end
