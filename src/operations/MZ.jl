"""
    MZ() <: Operation

The MZ operation is a single-qubit measurement operation that measures the state of a qubit in the Z basis.
"""
struct MZ <: MeasurementOperation end

function nQubits(::MZ)
    return 1
end
function isClifford(::MZ)
    return true
end
function nAncilla(::MZ)
    return 0
end
