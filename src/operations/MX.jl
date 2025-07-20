"""
    MX() <: Operation

The MX operation is a single-qubit measurement operation that measures the state of a qubit in the X basis.
"""
struct MX <: MeasurementOperation end

function nQubits(::MX)
    return 1
end
function isClifford(::MX)
    return true
end
function nAncilla(::MX)
    return 0
end
