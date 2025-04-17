"""
    Measure_X() <: Operation

The Measure_X operation is a single-qubit measurement operation that measures the state of a qubit in the X basis.
"""
struct Measure_X <: MeasurementOperation end

function nQubits(::Measure_X)
    return 1
end
function isClifford(::Measure_X)
    return true
end
function nAncilla(::Measure_X)
    return 0
end
