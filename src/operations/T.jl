"""
    T() <: Operation

The T operation is a single-qubit gate that applies a phase of π/4 to the |1⟩ state.
"""
struct T <: Operation end

function nQubits(::T)
    return 1
end
function isClifford(::T)
    return false
end
function nAncilla(::T)
    return 0
end
