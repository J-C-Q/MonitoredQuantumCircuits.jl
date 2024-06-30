"""
    YY() <: Operation

A singelton type representing the YY operation.
"""
struct YY <: Operation end

function nQubits(operation::YY)
    return 3
end
function isClifford(operation::YY)
    return true
end
function applyToQiskit!(qc::Qiskit.QuantumCircuit, operation::YY, position::Vararg{Integer})
    qc.reset(position[2] - 1)
    qc.sdg(position[2] - 1)
    qc.cx(position[2] - 1, position[1] - 1)
    qc.cx(position[2] - 1, position[3] - 1)
    qc.measure(position[2] - 1, position[2] - 1)
end
function connectionGraph(operation::YY)
    # return the connection graph of the operation
    return path_graph(3)
end
