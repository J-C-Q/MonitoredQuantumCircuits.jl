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
    function Circuit(lattice::Lattice, operations::Vector{Operation}, operationPositions::Vector{NTuple{N,M}}, operationPointers::Vector{M}, executionOrder::Vector{M}) where {M<:Integer,N}
        return new{typeof(lattice),M}(lattice, operations, operationPositions, operationPointers, executionOrder)
    end
end

"""
    EmptyCircuit(lattice::Lattice)

Create an empty circuit on the given lattice.
"""
EmptyCircuit(lattice::Lattice) = Circuit(lattice)
# """
#     NishimoriCircuit(lattice::Lattice)

# Create a Nishimori circuit on the given lattice, i.e. a circuit with one layer of ZZ operations on all bonds.
# """
# function NishimoriCircuit(lattice::Lattice)
#     operations = [ZZ()]

#     operationPositions = getBonds(lattice)
#     operationPointers = fill(1, length(operationPositions))
#     executionOrder = fill(1, length(operationPositions))
#     return Circuit(lattice, operations, operationPositions, operationPointers, executionOrder)
# end

"""
    apply!(circuit::Circuit, operation::Operation, position::Vararg{Integer})

Apply the given operation at the given position(s) in the circuit. Operations that act on more than one qubit need to have the same number of position arguments as qubits they act on, as well as a connection structure that is part of the lattice.
"""
function apply!(circuit::Circuit, operation::Operation, position::Vararg{Integer})
    _checkInBounds(circuit, operation, position...)

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
"""
    apply!(circuit::Circuit, executionPosition::Integer, operation::Operation, position::Vararg{Integer})

Apply the given operation at a given execution time step at the given position(s) in the circuit. The executionPosition can be used to schedule multiple operations at the same time step. However it is important to first check if the operations are compatible with each other (as of now this will show a warning which can be muted with ```mute=true```).
"""
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


function _checkInBounds(circuit::Circuit, operation::Operation, position::Vararg{Integer})
    if length(position) != nQubits(operation)
        throw(ArgumentError("Invalid number of position arguments for operation. Expected $(nQubits(operation)), got $(length(position)) $(position)"))
    end
    if any([pos < 1 || pos > length(circuit.lattice) for pos in position])
        throw(ArgumentError("Invalid position argument for operation. Expected between 1 and $(length(circuit.lattice)), got $(position)"))
    end
    # check that the connectionGraph of the operation is a subgraph of the lattice graph between the given positions
    subgraph = induced_subgraph(circuit.lattice.graph, [position...])
    if !Graphs.Experimental.has_induced_subgraphisomorph(subgraph[1], connectionGraph(operation), vertex_relation=(g1, g2) -> g1 == g2)
        throw(ArgumentError("The connection graph of the operation is not a subgraph of the lattice graph between the given positions"))
    end
end

function Base.show(io::IO, circuit::Circuit)
    println(io, "$(typeof(circuit)):")
    if isempty(circuit.operationPointers)
        println(io, "No operations defined")
    else
        # as many execution steps as operations -> step count is redundant
        if all(circuit.executionOrder .== 1:length(circuit.executionOrder))
            # too many operations to show all
            if length(circuit.operationPointers) > 10
                println(io, "with $(length(circuit.operationPointers)) operations")
            else
                println(io, "Operations: ")
                for (i, ptr) in enumerate(circuit.operationPointers)
                    println(io, "  ", circuit.operations[ptr], " at ", circuit.operationPositions[i])
                end
            end
        else
            uniqueExecutionSteps = sort(unique(circuit.executionOrder))
            # too many operations to show all
            if length(circuit.operationPointers) > 10
                # print steps/step depending on if more than one step
                if length(uniqueExecutionSteps) > 1
                    println(io, "with $(length(circuit.operationPointers)) operations in $(length(uniqueExecutionSteps)) steps")
                else
                    println(io, "with $(length(circuit.operationPointers)) operations in 1 step")
                end
            else
                println(io, "Operations: ")
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
end

function _getOperations(circuit::Circuit, executionPosition::Integer)
    operationsInStep = findall(circuit.executionOrder .== executionPosition)
    return operationsInStep
end
"""
    isClifford(circuit::Circuit)

Check if the circuit is a Clifford circuit, i.e. only contains Clifford operations.
Returns true if all operations are Clifford operations, false otherwise.
"""
function isClifford(circuit::Circuit)
    return all([isClifford(operation) for operation in circuit.operations])
end



# job.result()[0].data.c.get_counts().items()


function execute(::Circuit, backend::Backend; verbose::Bool=true)
    throw(ArgumentError("Backend $(typeof(backend)) not supported"))
end

function translate(type::Type, circuit::Circuit)
    throw(ArgumentError("Conversion from Circuit to $(typeof(type)) not supported"))
end
