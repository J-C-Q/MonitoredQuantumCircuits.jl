"""
    T() <: Operation

A singelton type representing the T operation.
"""
struct T <: Operation end

function nQubits(::T)
    return 1
end
function isClifford(::T)
    return false
end

# function connectionGraph(::T)
#     # return the connection graph of the operation
#     return path_graph(1)
# end
# function plotPositions(::T)
#     return [(0, 0)]
# end

# function color(::T)
#     return "#CB3C33"
# end

# function isAncilla(::T, qubit::Integer)
#     0 < qubit <= nQubits(T()) || throw(ArgumentError("qubit $qubit is not a valid qubit for the T operation."))
#     return false
# end
