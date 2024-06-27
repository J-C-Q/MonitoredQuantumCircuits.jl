# a general Operation type. All operations need to be subtypes of this abstract type. The operations need to implement the following methods:
abstract type Operation end
"""
    nQubits(operation::Operation)

Return the number of qubits the operation acts on.
"""
function nQubits(operation::Operation)
    throw(ArgumentError("nQubits not implemented for $(typeof(operation)). Please implement this method for your custom operation."))
end
"""
    isClifford(operation::Operation)

Return whether the operation is a Clifford operation.
"""
function isClifford(operation::Operation)
    throw(ArgumentError("isClifford not implemented for $(typeof(operation)). Please implement this method for your custom operation."))
end
"""
    qiskitRepresentation(operation::Operation)

Return the qiskit representation of the operation.
"""
function qiskitRepresentation(operation::Operation)
    throw(ArgumentError("qiskitRepresentation not implemented for $(typeof(operation)). Please implement this method for your custom operation."))
end

include("operations/ZZ.jl")
include("operations/XX.jl")
include("operations/YY.jl")

Base.show(io::IO, operation::Operation) = print(io, "$(typeof(operation))")
