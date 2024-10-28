function depth(::MonitoredQuantumCircuits.Measure, ::Type{StimCircuit})
    return 1
end


function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.Measure, p::Integer)
    qc.append("M", p - 1)
end
function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.Measure, step::Integer, p::Integer)
    apply!(qc, MonitoredQuantumCircuits.Measure(), Val(step), p)
end
function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.Measure, ::Val{1}, p::Integer)
    qc.append("M", p - 1)
end
