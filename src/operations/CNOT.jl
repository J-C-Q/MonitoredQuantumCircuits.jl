"""
    CNOT() <: Operation

A singelton type representing the CNOT operation.
"""
struct CNOT <: Operation end

function nQubits(::CNOT)
    return 2
end
function isClifford(::CNOT)
    return true
end

function connectionGraph(::CNOT)
    # return the connection graph of the operation
    return path_graph(2)
end
function plotPositions(::CNOT)
    return [(0, 0), (1, 0)]
end

function color(::CNOT)
    return "#CB3C33"
end

function isAncilla(::CNOT, qubit::Integer)
    0 < qubit <= nQubits(CNOT()) || throw(ArgumentError("qubit $qubit is not a valid qubit for the CNOT operation."))
    return false
end
