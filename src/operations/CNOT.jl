"""
    CNOT() <: Operation

The CNOT operation is a two-qubit gate that flips the target qubit if the control qubit is in the |1⟩ state.
"""
struct CNOT <: Operation end

function nQubits(::CNOT)
    return 2
end
function isClifford(::CNOT)
    return true
end
function nAncilla(::CNOT)
    return 0
end
