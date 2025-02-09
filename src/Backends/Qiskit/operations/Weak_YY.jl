function depth(::MonitoredQuantumCircuits.Weak_YY, ::Type{QuantumCircuit})
    return 6
end


function apply!(qc::QuantumCircuit, operation::MonitoredQuantumCircuits.Weak_YY, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    qc.sdg(p1 - 1)
    qc.reset(p2 - 1)
    qc.sdg(p3 - 1)
    qc.h(p1 - 1)
    qc.h(p2 - 1)
    qc.h(p3 - 1)
    qc.rzz(operation.t_A * 2, p1 - 1, p2 - 1)
    qc.rzz(operation.t_B * 2, p3 - 1, p2 - 1)
    qc.h(p1 - 1)
    qc.h(p2 - 1)
    qc.h(p3 - 1)
    qc.s(p1 - 1)
    qc.measure(p2 - 1, clbit - 1)
    qc.s(p3 - 1)
end

function apply!(qc::QuantumCircuit, operation::MonitoredQuantumCircuits.Weak_YY, step::Integer, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    apply!(qc, operation, Val(step), clbit, p1, p2, p3)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.Weak_YY, ::Val{1}, ::Integer, p1::Integer, p2::Integer, p3::Integer)
    qc.sdg(p1 - 1)
    qc.reset(p2 - 1)
    qc.sdg(p3 - 1)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.Weak_YY, ::Val{2}, ::Integer, p1::Integer, p2::Integer, p3::Integer)
    qc.h(p1 - 1)
    qc.h(p2 - 1)
    qc.h(p3 - 1)
end
function apply!(qc::QuantumCircuit, operation::MonitoredQuantumCircuits.Weak_YY, ::Val{3}, ::Integer, p1::Integer, p2::Integer, ::Integer)
    qc.rzz(operation.t_A * 2, p1 - 1, p2 - 1)
end
function apply!(qc::QuantumCircuit, operation::MonitoredQuantumCircuits.Weak_YY, ::Val{4}, ::Integer, ::Integer, p2::Integer, p3::Integer)
    qc.rzz(operation.t_B * 2, p3 - 1, p2 - 1)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.Weak_YY, ::Val{5}, clbit::Integer, ::Integer, p2::Integer, ::Integer)
    qc.h(p1 - 1)
    qc.h(p2 - 1)
    qc.h(p3 - 1)
end
function apply!(qc::QuantumCircuit, ::MonitoredQuantumCircuits.Weak_YY, ::Val{6}, clbit::Integer, ::Integer, p2::Integer, ::Integer)
    qc.s(p1 - 1)
    qc.measure(p2 - 1, clbit - 1)
    qc.s(p3 - 1)
end
