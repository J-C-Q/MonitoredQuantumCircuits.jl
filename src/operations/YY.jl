"""
    YY() <: MeasurementOperation

A singelton type representing a YY parity measurement operation.
"""
struct YY <: MeasurementOperation end

function nQubits(::YY)
    return 2
end
function isClifford(::YY)
    return true
end
function nancilla(::YY)
    return 1
end
# function connectionGraph(::YY)
#     # return the connection graph of the operation
#     return path_graph(3)
# end
# function plotPositions(::YY)
#     return [(0, 0), (1, 0), (2, 0)]
# end
# function color(::YY)
#     return "#389826"
# end

# function isAncilla(::YY, qubit::Integer)
#     0 < qubit <= nQubits(YY()) || throw(ArgumentError("qubit $qubit is not a valid qubit for the YY operation."))
#     return qubit == 2
# end

# function nMeasurements(::YY)
#     return 1
# end
