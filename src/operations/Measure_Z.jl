"""
    Measure_Z() <: Operation

The Measure_Z operation is a single-qubit measurement operation that measures the state of a qubit in the Z basis.
"""
struct Measure_Z <: MeasurementOperation end

function nQubits(::Measure_Z)
    return 1
end
function isClifford(::Measure_Z)
    return true
end
function nAncilla(::Measure_Z)
    return 0
end
