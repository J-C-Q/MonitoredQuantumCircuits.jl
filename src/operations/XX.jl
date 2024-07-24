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
function depth(::XX)
    return 6
end
function connectionGraph(::XX)
    # return the connection graph of the operation
    return path_graph(3)
end
