"""
    MY() <: Operation

The MY operation is a single-qubit measurement operation that measures the state of a qubit in the Y basis.
"""
struct MY <: MeasurementOperation end

function nQubits(::MY)
    return 1
end
function isClifford(::MY)
    return true
end
function nAncilla(::MY)
    return 0
end
