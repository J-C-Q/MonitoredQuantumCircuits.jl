function apply!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.I,
    p;
    keep_result::Bool=false)

    QC.apply!(state, QC.sId1(p[1]))
end
