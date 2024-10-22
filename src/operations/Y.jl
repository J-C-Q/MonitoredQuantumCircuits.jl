"""
    Y() <: Operation

A singelton type representing the Y operation.
"""
struct Y <: Operation end

function nQubits(::Y)
    return 1
end
function isClifford(::Y)
    return true
end

function connectionGraph(::Y)
    # return the connection graph of the operation
    return path_graph(1)
end
function plotPositions(::Y)
    return [(0, 0)]
end

function color(::Y)
    return "#CB3C33"
end

function isAncilla(::Y, qubit::Integer)
    0 < qubit <= nQubits(Y()) || throw(ArgumentError("qubit $qubit is not a valid qubit for the Y operation."))
    return false
end
