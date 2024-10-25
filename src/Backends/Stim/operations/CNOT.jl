function depth(::MonitoredQuantumCircuits.CNOT, ::Type{StimCircuit})
    return 1
end


function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.CNOT, p1::Integer, p2::Integer)
    qc.append("CNOT", [p1 - 1, p2 - 1])
end
function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.CNOT, step::Integer, p1::Integer, p2::Integer)
    apply!(qc, MonitoredQuantumCircuits.CNOT(), Val(step), p1, p2)
end
function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.CNOT, ::Val{1}, p1::Integer, p2::Integer)
    qc.append("CNOT", [p1 - 1, p2 - 1])
end
