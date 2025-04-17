"""
    S() <: Operation

The S operation is a single-qubit gate that applies a phase of π/2 to the |1⟩ state.
"""
struct S <: Operation end

function nQubits(::S)
    return 1
end
function isClifford(::S)
    return true
end
function nAncilla(::S)
    return 0
end
