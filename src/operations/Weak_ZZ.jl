"""
    Weak_ZZ <: MeasurementOperation

The Weak_ZZ operation is a three-qubit gate that applies a weak ZZ interaction between the first two qubits, with a strength determined by the parameter t. The third qubit is an ancilla qubit that is used to store the result of the operation.
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
function nAncilla(::Weak_ZZ)
    return 1
end
