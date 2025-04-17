"""
    XX() <: MeasurementOperation

The XX operation is a two-qubit gate that applies an XX interaction between the two qubits. It is a type of measurement operation that can be used in quantum circuits.
"""
struct XX <: MeasurementOperation end

function nQubits(::XX)
    return 2
end
function isClifford(::XX)
    return true
end
function nAncilla(::XX)
    return 1
end
