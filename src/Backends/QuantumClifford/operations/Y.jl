function apply!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.Y,
    p::Integer;
    keep_result::Bool=false)

    QC.apply!(state, QC.sY(p))
end


function apply_Y!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    p::Integer,
    keep_result::Bool=false)

    QC.apply!(state, QC.sY(p))
end

function apply!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.Y,
    p;
    keep_result::Bool=false)

    QC.apply!(state, QC.sY(p[1]))
end
