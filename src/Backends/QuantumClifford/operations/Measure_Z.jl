function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    ::MonitoredQuantumCircuits.Measure_Z,
    p::SubArray;
    keep_result::Bool=false)

    QC.projectZ!(state, p[1]; keep_result)
end
