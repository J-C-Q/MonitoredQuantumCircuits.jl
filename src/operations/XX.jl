"""
    XX() <: Operation

A singelton type representing the XX operation.
"""
struct XX <: Operation end

function nQubits(::XX)
    return 3
end
function isClifford(::XX)
    return true
end
function applyToQiskit!(qc::Qiskit.QuantumCircuit, ::XX, position::Vararg{Integer})
    qc.reset(position[2] - 1)
    qc.h(position[2] - 1)
    qc.cx(position[2] - 1, position[1] - 1)
    qc.cx(position[2] - 1, position[3] - 1)
    qc.measure(position[2] - 1, position[2] - 1)
end
function connectionGraph(::XX)
    # return the connection graph of the operation
    return path_graph(3)
end
