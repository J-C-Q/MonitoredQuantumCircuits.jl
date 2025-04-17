"""
    Weak_YY <: MeasurementOperation

The Weak_YY operation is a three-qubit gate that applies a weak YY interaction between the first two qubits, with a strength determined by the parameter t. The third qubit is an ancilla qubit that is used to store the result of the operation.
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
function nAncilla(::Weak_YY)
    return 1
end
