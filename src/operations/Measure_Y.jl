"""
    Measure_Y() <: Operation

The Measure_Y operation is a single-qubit measurement operation that measures the state of a qubit in the Y basis.
"""
struct Measure_Y <: MeasurementOperation end

function nQubits(::Measure_Y)
    return 1
end
function isClifford(::Measure_Y)
    return true
end
function nAncilla(::Measure_Y)
    return 0
end
