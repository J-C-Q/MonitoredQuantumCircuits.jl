"""
    Measure() <: Operation

A singelton type representing the computational basis measurement operation.
"""
struct Measure_Z <: MeasurementOperation end


function nQubits(::Measure_Z)
    return 1
end
function isClifford(::Measure_Z)
    return true
end
function nancilla(::Measure_Z)
    return 0
end
# function connectionGraph(::Measure)
#     # return the connection graph of the operation
#     return path_graph(1)
# end
# function plotPositions(::Measure)
#     return [(0, 0)]
# end

# function color(::Measure)
#     return "#CB3C33"
# end

# # function isAncilla(::H, qubit::Integer)
# #     0 < qubit <= nQubits(H()) || throw(ArgumentError("qubit $qubit is not a valid qubit for the H operation."))
# #     return false
# # end

# function nMeasurements(::Measure)
#     return 1
# end
