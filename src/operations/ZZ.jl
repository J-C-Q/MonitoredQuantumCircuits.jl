"""
    ZZ() <: Operation

A singelton type representing the ZZ operation.
"""
struct ZZ <: Operation end

function nQubits(operation::ZZ)
    return 3
end
function isClifford(operation::ZZ)
    return true
end
function applyToQiskit!(qc::Qiskit.QuantumCircuit, operation::ZZ, position::Vararg{Integer})
    qc.reset(position[2] - 1)
    qc.cx(position[1] - 1, position[2] - 1)
    qc.cx(position[3] - 1, position[2] - 1)
    qc.measure(position[2] - 1, position[2] - 1)
end
function connectionGraph(operation::ZZ)
    # return the connection graph of the operation
    return path_graph(3)
end
