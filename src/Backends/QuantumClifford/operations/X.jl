function apply!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.X,
    p::Integer;
    keep_result::Bool=false)

    QC.apply!(state, QC.sX(p))
end

function apply_X!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    p::Integer,
    keep_result::Bool=false)

    QC.apply!(state, QC.sX(p))
end

function apply!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.X,
    p;
    keep_result::Bool=false)

    QC.apply!(state, QC.sX(p[1]))
end
