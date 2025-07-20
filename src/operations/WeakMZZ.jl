"""
    WeakMZZ <: MeasurementOperation

The WeakMZZ operation is a three-qubit gate that applies a weak ZZ interaction between the first two qubits, with a strength determined by the parameter t. The third qubit is an ancilla qubit that is used to store the result of the operation.
"""
struct WeakMZZ <: MeasurementOperation
    t::Float64
    function WeakMZZ(t::Float64)
        0 < t <= π / 4 || throw(ArgumentError("t must be in (0, π/4]."))
        new(t)
    end
end
function nQubits(::WeakMZZ)
    return 3
end
function isClifford(::WeakMZZ)
    return false
end
function nAncilla(::WeakMZZ)
    return 1
end
