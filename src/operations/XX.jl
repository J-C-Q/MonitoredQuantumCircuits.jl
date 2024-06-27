"""
    XX() <: Operation

A singelton type representing the XX operation.
"""
struct XX <: Operation end

function nQubits(operation::XX)
    return 2
end
function isClifford(operation::XX)
    return true
end
function qiskitRepresentation(operation::XX)
    # return the qiskit representation of the operation
end
