function depth(::MonitoredQuantumCircuits.YY, ::Type{QuantumCircuit})
    return 6
end


function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.YY, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    qc.reset(p2 - 1)
    qc.sdg(p2 - 1)
    qc.cx(p2 - 1, p1 - 1)
    qc.cx(p2 - 1, p3 - 1)
    qc.h(p2 - 1)
    qc.measure(p2 - 1, clbit - 1)
end

function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.YY, step::Integer, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    apply!(qc, MonitoredQuantumCircuits.YY(), Val(step), clbit, p1, p2, p3)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.YY, ::Val{1}, ::Integer, ::Integer, p2::Integer, ::Integer)
    qc.reset(p2 - 1)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.YY, ::Val{2}, ::Integer, ::Integer, p2::Integer, ::Integer)
    qc.sdg(p2 - 1)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.YY, ::Val{3}, ::Integer, p1::Integer, p2::Integer, ::Integer)
    qc.cx(p2 - 1, p1 - 1)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.YY, ::Val{4}, ::Integer, ::Integer, p2::Integer, p3::Integer)
    qc.cx(p2 - 1, p3 - 1)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.YY, ::Val{5}, ::Integer, ::Integer, p2::Integer, ::Integer)
    qc.h(p2 - 1)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.YY, ::Val{6}, clbit::Integer, ::Integer, p2::Integer, ::Integer)
    qc.measure(p2 - 1, clbit - 1)
end
