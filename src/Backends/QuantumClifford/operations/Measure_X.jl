function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    ::MonitoredQuantumCircuits.Measure_X,
    p::SubArray;
    keep_result::Bool=false)

    QC.projectX!(state, p[1]; keep_result)
end
