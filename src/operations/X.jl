"""
    X() <: Operation

The X operation is a single-qubit gate that flips the state of a qubit.
"""
struct X <: Operation end

function nQubits(::X)
    return 1
end
function isClifford(::X)
    return true
end
function nAncilla(::X)
    return 0
end
