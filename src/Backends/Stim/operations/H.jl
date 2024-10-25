function depth(::MonitoredQuantumCircuits.H, ::Type{StimCircuit})
    return 1
end


function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.H, p::Integer)
    qc.append("H", p - 1)
end
function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.H, step::Integer, p::Integer)
    apply!(qc, MonitoredQuantumCircuits.H(), Val(step), p)
end
function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.H, ::Val{1}, p::Integer)
    qc.append("H", p - 1)
end
