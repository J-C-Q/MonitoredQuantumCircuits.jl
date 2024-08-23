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

function connectionGraph(::ZZ)
    # return the connection graph of the operation
    return path_graph(3)
end
function plotPositions(::ZZ)
    return [(0, 0), (1, 0), (2, 0)]
end
function color(::ZZ)
    return "#4063D8"
end
