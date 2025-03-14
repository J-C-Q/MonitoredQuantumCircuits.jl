function apply!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.Z,
    p::Integer;
    keep_result::Bool=false)

    QC.apply!(state, QC.sZ(p))
end


function apply_Z!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    p::Integer,
    keep_result::Bool=false)

    QC.apply!(state, QC.sZ(p))
end

function apply!(
    state::QC.MixedDestabilizer,
    ::TableauSimulator,
    ::MonitoredQuantumCircuits.Z,
    p;
    keep_result::Bool=false)

    QC.apply!(state, QC.sZ(p[1]))
end
