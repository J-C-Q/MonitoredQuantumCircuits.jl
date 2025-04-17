"""
    Z() <: Operation

The Z operation is a single-qubit gate that applies a phase of π to the |1⟩ state.
"""
struct Z <: Operation end

function nQubits(::Z)
    return 1
end
function isClifford(::Z)
    return true
end
function nAncilla(::Z)
    return 0
end
