"""
    Y() <: Operation

The Y operation is a single-qubit gate that applies a phase of π to the |1⟩ state.
"""
struct Y <: Operation end

function nQubits(::Y)
    return 1
end
function isClifford(::Y)
    return true
end
function nAncilla(::Y)
    return 0
end
