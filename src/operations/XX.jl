"""
    XX() <: Operation

A singelton type representing the XX operation.
"""
struct XX <: MeasurementOperation end

function nQubits(::XX)
    return 3
end
function isClifford(::XX)
    return true
end

function connectionGraph(::XX)
    # return the connection graph of the operation
    return path_graph(3)
end
function plotPositions(::XX)
    return [(0, 0), (1, 0), (2, 0)]
end

function color(::XX)
    return "#CB3C33"
end

function isAncilla(::XX, qubit::Integer)
    0 < qubit <= nQubits(XX()) || throw(ArgumentError("qubit $qubit is not a valid qubit for the XX operation."))
    return qubit == 2
end

function nMeasurements(::XX)
    return 1
end
