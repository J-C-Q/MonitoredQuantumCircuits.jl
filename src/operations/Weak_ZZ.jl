"""
    Weak_ZZ(t) <: Operation

A singelton type representing the weak ZZ operation.
"""
struct Weak_ZZ <: MeasurementOperation
    t_A::Float64
    t_B::Float64
    function Weak_ZZ(t::Float64)
        0 < t <= π / 4 || throw(ArgumentError("t must be in (0, π/4]."))
        new(t, π / 4)
    end
    function Weak_ZZ(t_A::Float64, t_B::Float64)
        0 < t_A <= π / 4 || throw(ArgumentError("t_A must be in (0, π/4]."))
        0 < t_B <= π / 4 || throw(ArgumentError("t_B must be in (0, π/4]."))
        new(t_A, t_B)
    end
end


function nQubits(::Weak_ZZ)
    return 3
end
function isClifford(::Weak_ZZ)
    return false
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
