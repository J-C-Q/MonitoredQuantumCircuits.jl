"""
    Z() <: Operation

A singelton type representing the Pauli Z operation.
"""
struct Z <: Operation end

function nQubits(::Z)
    return 1
end
function isClifford(::Z)
    return true
end
function nancilla(::Z)
    return 0
end
# function connectionGraph(::Z)
#     # return the connection graph of the operation
#     return path_graph(1)
# end
# function plotPositions(::Z)
#     return [(0, 0)]
# end

# function color(::Z)
#     return "#CB3C33"
# end

# function isAncilla(::Z, qubit::Integer)
#     0 < qubit <= nQubits(Z()) || throw(ArgumentError("qubit $qubit is not a valid qubit for the Z operation."))
#     return false
# end
