"""
    I() <: Operation

The I operation is a single-qubit gate that represents the identity operation, leaving the qubit unchanged.
"""
struct I <: Operation end

function nQubits(::I)
    return 1
end
function isClifford(::I)
    return true
end
function nAncilla(::I)
    return 0
end
