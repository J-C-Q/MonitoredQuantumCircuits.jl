"""
    WeakMYY <: MeasurementOperation

The WeakMYY operation is a three-qubit gate that applies a weak YY interaction between the first two qubits, with a strength determined by the parameter t. The third qubit is an ancilla qubit that is used to store the result of the operation.
"""
struct WeakMYY <: MeasurementOperation
    t::Float64
    function WeakMYY(t::Float64)
        0 < t <= π / 4 || throw(ArgumentError("t must be in (0, π/4)."))
        new(t)
    end
end
function nQubits(::WeakMYY)
    return 3
end
function isClifford(::WeakMYY)
    return false
end
function nAncilla(::WeakMYY)
    return 1
end
