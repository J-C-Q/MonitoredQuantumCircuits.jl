function apply!(tc::ITensorCircuit, ::ZZ, p1::Integer, p2::Integer, p3::Integer)

    qc.reset(p2 - 1)
    qc.cx(p1 - 1, p2 - 1)
    qc.cx(p3 - 1, p2 - 1)
    qc.measure(p2 - 1, p2 - 1)
end
function apply!(qc::QuantumCircuit, ::ZZ, step::Integer, p1::Integer, p2::Integer, p3::Integer)
    apply!(qc, ZZ(), Val(step), p1, p2, p3)
end
function apply!(qc::QuantumCircuit, ::ZZ, ::Val{1}, ::Integer, p2::Integer, ::Integer)
    qc.reset(p2 - 1)
end
function apply!(qc::QuantumCircuit, ::ZZ, ::Val{2}, p1::Integer, p2::Integer, ::Integer)
    qc.cx(p1 - 1, p2 - 1)
end
function apply!(qc::QuantumCircuit, ::ZZ, ::Val{3}, ::Integer, p2::Integer, p3::Integer)
    qc.cx(p3 - 1, p2 - 1)
end
function apply!(qc::QuantumCircuit, ::ZZ, ::Val{4}, ::Integer, p2::Integer, ::Integer)
    qc.measure(p2 - 1, p2 - 1)
end
