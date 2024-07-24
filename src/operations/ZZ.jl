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
