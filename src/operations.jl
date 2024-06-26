abstract type Operation end

# this structure defines a singelton operation
struct ZZ <: Operation end

function nQubits(operation::ZZ)
    return 2
end
function isClifford(operation::ZZ)
    return true
end
function qiskitRepresentation(operation::ZZ)
    # return the qiskit representation of the operation
end

struct XX <: Operation end

function nQubits(operation::XX)
    return 2
end
function isClifford(operation::XX)
    return true
end
struct YY <: Operation end

function nQubits(operation::YY)
    return 2
end
function isClifford(operation::YY)
    return true
end
Base.show(io::IO, operation::Operation) = print(io, "$(typeof(operation))")
