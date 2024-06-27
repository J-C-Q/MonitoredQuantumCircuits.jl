"""
    ZZ() <: Operation

A singelton type representing the XX operation.
"""
struct ZZ <: Operation end

function nQubits(operation::ZZ)
    return 3
end
function isClifford(operation::ZZ)
    return true
end
function qiskitRepresentation(operation::ZZ)
    # return the qiskit representation of the operation
end
