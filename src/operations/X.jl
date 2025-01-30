"""
    X() <: Operation

A singelton type representing the I operation.
"""
struct X <: Operation end

function nQubits(::X)
    return 1
end
function isClifford(::X)
    return true
end

# function connectionGraph(::X)
#     # return the connection graph of the operation
#     return path_graph(1)
# end
# function plotPositions(::X)
#     return [(0, 0)]
# end

# function color(::X)
#     return "#CB3C33"
# end

# function isAncilla(::X, qubit::Integer)
#     0 < qubit <= nQubits(X()) || throw(ArgumentError("qubit $qubit is not a valid qubit for the X operation."))
#     return false
# end
