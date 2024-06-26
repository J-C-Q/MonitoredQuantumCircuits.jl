struct Circuit{T<:Lattice,M<:Integer}
    lattice::T
    operations::Vector{Operation} # the (unique) operations
    operationPositions::Vector{Tuple{M,Vararg{M}}} # the position where the operations get applied
    operationPointers::Vector{M} # the pointer to which operation gets applied at the position
    executionOrder::Vector{M} # the order in which the operations get executed

    function Circuit(lattice::Lattice)
        M = Int64
        return new{typeof(lattice),M}(lattice, Operation[], Tuple{M,Vararg{M}}[], M[], M[])
    end
    function Circuit(lattice::Lattice, operations::Vector{O}, operationPositions::Vector{NTuple{N,M}}, operationPointers::Vector{M}, executionOrder::Vector{M}) where {O<:Operation,M<:Integer,N}
        return new{typeof(lattice),M}(lattice, operations, operationPositions, operationPointers, executionOrder)
    end
end

EmptyCircuit(lattice::Lattice) = Circuit(lattice)
function NishimoriCircuit(lattice::Lattice)
    operations = [ZZ()]
    operationPositions = getBonds(lattice)
    operationPointers = fill(1, length(operationPositions))
    executionOrder = fill(1, length(operationPositions))
    return Circuit(lattice, operations, operationPositions, operationPointers, executionOrder)
end

function apply!(circuit::Circuit, operation::Operation, position::Vararg{Integer})
    if length(position) != nQubits(operation)
        throw(ArgumentError("Invalid number of position arguments for operation. Expected $(nQubits(operation)), got $(length(position)) $(position)"))
    end
    if any([pos < 1 || pos > length(circuit.lattice) for pos in position])
        throw(ArgumentError("Invalid position argument for operation. Expected between 1 and $(length(circuit.lattice)), got $(position)"))
    end

    if operation in circuit.operations
        index = findfirst([op == operation for op in circuit.operations])
    else
        push!(circuit.operations, operation)
        index = length(circuit.operations)
    end
    push!(circuit.operationPositions, position)
    push!(circuit.operationPointers, index)
    if isempty(circuit.executionOrder)
        push!(circuit.executionOrder, 1)
    else
        push!(circuit.executionOrder, maximum(circuit.executionOrder) + 1)
    end
    return circuit
end

function apply!(circuit::Circuit, executionPosition::Integer, operation::Operation, position::Vararg{Integer}; mute::Bool=false)
    # TODO check if operation is compatible with other operations at the same execution position
    simultaniusOperations = _getOperations(circuit, executionPosition)
    if !mute && !isempty(simultaniusOperations)
        warmMessage = "Make sure that $operation at $position can be executed at the same time as \n"
        for operation in simultaniusOperations
            warmMessage *= "$(circuit.operations[circuit.operationPointers[operation]]) at $(circuit.operationPositions[operation])\n"
        end
        @warn warmMessage
    end
    circuit = apply!(circuit, operation, position...)
    circuit.executionOrder[end] = executionPosition
    return circuit
end

function Base.show(io::IO, circuit::Circuit)
    println(io, "$(typeof(circuit)):")
    if isempty(circuit.operationPointers)
        println(io, "No operations defined")
    else
        println(io, "Operations: ")
        if all(circuit.executionOrder .== 1:length(circuit.executionOrder))
            for (i, ptr) in enumerate(circuit.operationPointers)
                println(io, "  ", circuit.operations[ptr], " at ", circuit.operationPositions[i])
            end
        else
            uniqueExecutionSteps = sort(unique(circuit.executionOrder))
            for (i, step) in enumerate(uniqueExecutionSteps)
                println(io, "  Step $step:")
                operationsInStep = findall(circuit.executionOrder .== step)
                for operation in operationsInStep
                    println(io, "    ", circuit.operations[circuit.operationPointers[operation]], " at ", circuit.operationPositions[operation])
                end
            end
        end

    end
end

function _getOperations(circuit::Circuit, executionPosition::Integer)
    operationsInStep = findall(circuit.executionOrder .== executionPosition)
    return operationsInStep
end

function isClifford(circuit::Circuit)
    return all([isClifford(operation) for operation in circuit.operations])
end
