"""
    S() <: Operation

A singelton type representing the S operation.
"""
struct S <: Operation end

function nQubits(::S)
    return 1
end
function isClifford(::S)
    return true
end

# function connectionGraph(::S)
#     # return the connection graph of the operation
#     return path_graph(1)
# end
# function plotPositions(::S)
#     return [(0, 0)]
# end

# function color(::S)
#     return "#CB3C33"
# end

# function isAncilla(::S, qubit::Integer)
#     0 < qubit <= nQubits(S()) || throw(ArgumentError("qubit $qubit is not a valid qubit for the S operation."))
#     return false
# end
