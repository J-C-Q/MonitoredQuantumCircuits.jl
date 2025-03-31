"""
    Weak_YY(t) <: Operation

A singelton type representing the weak YY operation.
"""
struct Weak_YY <: MeasurementOperation
    t::Float64
    function Weak_YY(t::Float64)
        0 < t <= π / 4 || throw(ArgumentError("t must be in (0, π/4)."))
        new(t)
    end
end


function nQubits(::Weak_YY)
    return 3
end
function isClifford(::Weak_YY)
    return false
end
function getParameter(o::Weak_YY)
    return [o.t]
end
function nancilla(::Weak_YY)
    return 1
end
# function connectionGraph(::Weak_YY)
#     # return the connection graph of the operation
#     return path_graph(3)
# end
# function plotPositions(::Weak_YY)
#     return [(0, 0), (1, 0), (2, 0)]
# end
# function color(::Weak_YY)
#     return "#4063D8"
# end
# function isAncilla(operation::Weak_YY, qubit::Integer)
#     0 < qubit <= nQubits(operation) || throw(ArgumentError("qubit $qubit is not a valid qubit for the Weak_YY operation."))
#     return qubit == 2
# end

# function nMeasurements(::Weak_YY)
#     return 1
# end
