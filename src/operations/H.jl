"""
    H() <: Operation

A singelton type representing the H operation.
"""
struct H <: Operation end

# function H!(circuit::Circuit, p::Integer)
#     apply!(circuit, H(), p)
# end

function nQubits(::H)
    return 1
end
function isClifford(::H)
    return true
end
function nancilla(::H)
    return 0
end
# function connectionGraph(::H)
#     # return the connection graph of the operation
#     return path_graph(1)
# end
# function plotPositions(::H)
#     return [(0, 0)]
# end

# function color(::H)
#     return "#CB3C33"
# end

# function isAncilla(::H, qubit::Integer)
#     0 < qubit <= nQubits(H()) || throw(ArgumentError("qubit $qubit is not a valid qubit for the H operation."))
#     return false
# end
