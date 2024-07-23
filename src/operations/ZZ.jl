"""
    ZZ() <: Operation

A singelton type representing the ZZ operation.
"""
struct ZZ <: Operation end

function nQubits(::ZZ)
    return 3
end
function isClifford(::ZZ)
    return true
end
function depth(::ZZ)
    return 4
end
function connectionGraph(::ZZ)
    # return the connection graph of the operation
    return path_graph(3)
end



function applyToQiskit!(qc::Qiskit.QuantumCircuit, ::ZZ, p1::Integer, p2::Integer, p3::Integer)
    qc.reset(p2 - 1)
    qc.cx(p1 - 1, p2 - 1)
    qc.cx(p3 - 1, p2 - 1)
    qc.measure(p2 - 1, p2 - 1)
end
function applyToQiskit!(qc::Qiskit.QuantumCircuit, ::ZZ, step::Integer, p1::Integer, p2::Integer, p3::Integer)
    applyToQiskit!(qc, ZZ(), Val(step), p1, p2, p3)
end
function applyToQiskit!(qc::Qiskit.QuantumCircuit, ::ZZ, ::Val{1}, ::Integer, p2::Integer, ::Integer)
    qc.reset(p2 - 1)
end
function applyToQiskit!(qc::Qiskit.QuantumCircuit, ::ZZ, ::Val{2}, p1::Integer, p2::Integer, ::Integer)
    qc.cx(p1 - 1, p2 - 1)
end
function applyToQiskit!(qc::Qiskit.QuantumCircuit, ::ZZ, ::Val{3}, ::Integer, p2::Integer, p3::Integer)
    qc.cx(p3 - 1, p2 - 1)
end
function applyToQiskit!(qc::Qiskit.QuantumCircuit, ::ZZ, ::Val{4}, ::Integer, p2::Integer, ::Integer)
    qc.measure(p2 - 1, p2 - 1)
end
