"""
    YY() <: Operation

A singelton type representing the YY operation.
"""
struct YY <: Operation end

function nQubits(::YY)
    return 3
end
function isClifford(::YY)
    return true
end
function applyToQiskit!(qc::Qiskit.QuantumCircuit, ::YY, position::Vararg{Integer})
    qc.reset(position[2] - 1)
    qc.sdg(position[2] - 1)
    qc.cx(position[2] - 1, position[1] - 1)
    qc.cx(position[2] - 1, position[3] - 1)
    qc.measure(position[2] - 1, position[2] - 1)
end
function connectionGraph(::YY)
    # return the connection graph of the operation
    return path_graph(3)
end
