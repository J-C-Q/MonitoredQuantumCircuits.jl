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
    connectionGraph(operation::Operation)

Return a graph representing the unique gate connections of the operation.
"""
function connectionGraph(operation::Operation)
    throw(ArgumentError("connectionGraph not implemented for $(typeof(operation)). Please implement this method for your custom operation."))
end

"""
    depth(operation::Operation)

Return the depth of the operation.
"""
function depth(operation::Operation)
    throw(ArgumentError("depth not implemented for $(typeof(operation)). Please implement this method for your custom operation."))
end



Base.show(io::IO, operation::Operation) = print(io, "$(typeof(operation))")
