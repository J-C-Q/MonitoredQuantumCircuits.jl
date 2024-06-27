"""
    YY() <: Operation

A singelton type representing the XX operation.
"""
struct YY <: Operation end

function nQubits(operation::YY)
    return 2
end
function isClifford(operation::YY)
    return true
end
function qiskitRepresentation(operation::YY)
    # return the qiskit representation of the operation
end
