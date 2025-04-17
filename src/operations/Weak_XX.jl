"""
    Weak_XX <: MeasurementOperation

The Weak_XX operation is a three-qubit gate that applies a weak XX interaction between the first two qubits, with a strength determined by the parameter t. The third qubit is an ancilla qubit that is used to store the result of the operation.
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
function nAncilla(::Weak_XX)
    return 1
end
