"""
    ZZ() <: MeasurementOperation

A singelton type representing a ZZ parity measurement operation.
"""
struct ZZ <: MeasurementOperation end

function nQubits(::ZZ)
    return 2
end
function isClifford(::ZZ)
    return true
end
function nancilla(::ZZ)
    return 1
end
# function connectionGraph(::ZZ)
#     # return the connection graph of the operation
#     return path_graph(3)
# end
# function plotPositions(::ZZ)
#     return [(0, 0), (1, 0), (2, 0)]
# end
# function color(::ZZ)
#     return "#4063D8"
# end
# function isAncilla(::ZZ, qubit::Integer)
#     0 < qubit <= nQubits(ZZ()) || throw(ArgumentError("qubit $qubit is not a valid qubit for the ZZ operation."))
#     return qubit == 2
# end

# function nMeasurements(::ZZ)
#     return 1
# end
