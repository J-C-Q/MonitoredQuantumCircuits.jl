function depth(::MonitoredQuantumCircuits.H, ::Type{QuantumCircuit})
    return 1
end


function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.H, p::Integer)
    qc.h(p - 1)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.H, step::Integer, p::Integer)
    apply!(qc, MonitoredQuantumCircuits.H(), Val(step), p)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.H, ::Val{1}, p::Integer)
    qc.h(p - 1)
end
