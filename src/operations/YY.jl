"""
    YY() <: MeasurementOperation

The YY operation is a two-qubit gate that applies a YY interaction between the two qubits. The operation is used to measure the state of the qubits in the YY basis.
"""
struct YY <: MeasurementOperation end

function nQubits(::YY)
    return 2
end
function isClifford(::YY)
    return true
end
function nAncilla(::YY)
    return 1
end
