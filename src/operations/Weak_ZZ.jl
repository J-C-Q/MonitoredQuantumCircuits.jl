"""
    Weak_ZZ(t) <: Operation

A type representing the weak ZZ operation.
"""
struct Weak_ZZ <: MeasurementOperation
    t::Float64
    function Weak_ZZ(t::Float64)
        0 < t <= π / 4 || throw(ArgumentError("t must be in (0, π/4]."))
        new(t)
    end
end


function nQubits(::Weak_ZZ)
    return 3
end
function isClifford(::Weak_ZZ)
    return false
end
function getParameter(o::Weak_ZZ)
    return [o.t]
end
function nancilla(::Weak_ZZ)
    return 1
end
# function connectionGraph(::Weak_ZZ)
#     # return the connection graph of the operation
#     return path_graph(3)
# end
# function plotPositions(::Weak_ZZ)
#     return [(0, 0), (1, 0), (2, 0)]
# end
# function color(::Weak_ZZ)
#     return "#4063D8"
# end
# function isAncilla(operation::Weak_ZZ, qubit::Integer)
#     0 < qubit <= nQubits(operation) || throw(ArgumentError("qubit $qubit is not a valid qubit for the Weak_ZZ operation."))
#     return qubit == 2
# end

# function nMeasurements(::Weak_ZZ)
#     return 1
# end

# function ZZ(t::Float64)
#     if t == 0
#         return I()
#     elseif t == π / 4
#         return ZZ()
#     end
#     return Weak_ZZ(t)
# end
