"""
    H() <: Operation

The H operation is a single-qubit gate that creates superposition by applying a Hadamard transformation.
"""
struct H <: Operation end

function nQubits(::H)
    return 1
end
function isClifford(::H)
    return true
end
function nAncilla(::H)
    return 0
end
