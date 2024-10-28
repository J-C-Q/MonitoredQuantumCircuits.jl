function depth(::MonitoredQuantumCircuits.ZZ, ::Type{QuantumCircuit})
    return 4
end


function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.ZZ, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    qc.reset(p2 - 1)
    qc.cx(p1 - 1, p2 - 1)
    qc.cx(p3 - 1, p2 - 1)
    qc.measure(p2 - 1, clbit - 1)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.ZZ, step::Integer, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    apply!(qc, MonitoredQuantumCircuits.ZZ(), Val(step), clbit, p1, p2, p3)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.ZZ, ::Val{1}, ::Integer, ::Integer, p2::Integer, ::Integer)
    qc.reset(p2 - 1)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.ZZ, ::Val{2}, ::Integer, p1::Integer, p2::Integer, ::Integer)
    qc.cx(p1 - 1, p2 - 1)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.ZZ, ::Val{3}, ::Integer, ::Integer, p2::Integer, p3::Integer)
    qc.cx(p3 - 1, p2 - 1)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.ZZ, ::Val{4}, clbit::Integer, ::Integer, p2::Integer, ::Integer)
    qc.measure(p2 - 1, clbit - 1)
end
