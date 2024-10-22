"""
    I() <: Operation

A singelton type representing the I operation.
"""
struct I <: Operation end

function nQubits(::I)
    return 1
end
function isClifford(::I)
    return true
end

function connectionGraph(::I)
    # return the connection graph of the operation
    return path_graph(1)
end
function plotPositions(::I)
    return [(0, 0)]
end

function color(::I)
    return "#CB3C33"
end

function isAncilla(::I, qubit::Integer)
    0 < qubit <= nQubits(I()) || throw(ArgumentError("qubit $qubit is not a valid qubit for the I operation."))
    return false
end
