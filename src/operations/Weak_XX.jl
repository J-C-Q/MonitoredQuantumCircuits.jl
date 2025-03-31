"""
    Weak_XX(t) <: Operation

A singelton type representing the weak XX operation.
"""
struct Weak_XX <: MeasurementOperation
    t::Float64
    function Weak_XX(t::Float64)
        0 < t <= π / 4 || throw(ArgumentError("t must be in (0, π/4)."))
        new(t)
    end
end


function nQubits(::Weak_XX)
    return 3
end
function isClifford(::Weak_XX)
    return false
end
function getParameter(o::Weak_XX)
    floatParamter = [o.t]
    intParameter = []
    return (floatParamter, intParameter)
end
function hasParameter(::Type{Weak_XX})
    return true
end
function hasParameter(::Type{Weak_XX}, ::Type{Float64})
    return true
end
function nancilla(::Weak_XX)
    return 1
end

# function connectionGraph(::Weak_XX)
#     # return the connection graph of the operation
#     return path_graph(3)
# end
# function plotPositions(::Weak_XX)
#     return [(0, 0), (1, 0), (2, 0)]
# end
# function color(::Weak_XX)
#     return "#4063D8"
# end
# function isAncilla(operation::Weak_XX, qubit::Integer)
#     0 < qubit <= nQubits(operation) || throw(ArgumentError("qubit $qubit is not a valid qubit for the Weak_XX operation."))
#     return qubit == 2
# end

# function nMeasurements(::Weak_XX)
#     return 1
# end
