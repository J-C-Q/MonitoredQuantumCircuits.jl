function apply!(qc::QuantumCircuit, ::YY, p1::Integer, p2::Integer, p3::Integer)
    qc.reset(p2 - 1)
    qc.sdg(p2 - 1)
    qc.cx(p2 - 1, p1 - 1)
    qc.cx(p2 - 1, p3 - 1)
    qc.h(p2 - 1)
    qc.measure(p2 - 1, p2 - 1)
end

function apply!(qc::QuantumCircuit, ::YY, step::Integer, p1::Integer, p2::Integer, p3::Integer)
    apply!(qc, YY(), Val(step), p1, p2, p3)
end
function apply!(qc::QuantumCircuit, ::YY, ::Val{1}, ::Integer, p2::Integer, ::Integer)
    qc.reset(p2 - 1)
end
function apply!(qc::QuantumCircuit, ::YY, ::Val{2}, ::Integer, p2::Integer, ::Integer)
    qc.sdg(p2 - 1)
end
function apply!(qc::QuantumCircuit, ::YY, ::Val{3}, p1::Integer, p2::Integer, ::Integer)
    qc.cx(p2 - 1, p1 - 1)
end
function apply!(qc::QuantumCircuit, ::YY, ::Val{4}, ::Integer, p2::Integer, p3::Integer)
    qc.cx(p2 - 1, p3 - 1)
end
function apply!(qc::QuantumCircuit, ::YY, ::Val{5}, ::Integer, p2::Integer, ::Integer)
    qc.h(p2 - 1)
end
function apply!(qc::QuantumCircuit, ::YY, ::Val{6}, ::Integer, p2::Integer, ::Integer)
    qc.measure(p2 - 1, p2 - 1)
end
