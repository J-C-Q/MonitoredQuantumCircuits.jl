function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    ::MonitoredQuantumCircuits.Measure_Y,
    p::SubArray;
    keep_result::Bool=false)

    QC.projectY!(state, p[1]; keep_result)
end
