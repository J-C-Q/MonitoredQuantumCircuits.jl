# We need two circuit structures. One for interacivly creating the circuit. And one for efficently storing the circuit (optimized for iteration).
using StaticArrays

struct Position
    positions::Matrix{Int64}
    weights::StatsBase.Weights{Float64,Float64,Vector{Float64}}
    function Position(position::Vararg{Integer})
        new(reshape([position...], (length(position),1)), StatsBase.Weights([1.0]))
    end
    function Position(positions::Matrix, probabilities::Vector)
        new(positions, StatsBase.Weights(probabilities))
    end
end
struct Instruction
    operations::Vector{Int64}
    positions::Vector{Int64}
    weights::StatsBase.Weights{Float64,Float64,Vector{Float64}}
    function Instruction(operation::Integer, position::Integer)
        new([operation],[position], StatsBase.Weights([1.0]))
    end
    function Instruction(operations::Vector,positions::Vector,probabilities::Vector)
        new(operations,positions, StatsBase.Weights(probabilities))
    end
end

# Circuit optimized for interactive construction
"""
    CircuitConstructor{G<:Geometry}
A circuit optimized for interactive construction. The operations are stored in a vector to allow for efficient construction.
"""
struct CircuitConstructor{G<:Geometry}
    geometry::Geometry
    operations::Vector{Operation} #inefficient
    operationHashTable::Dict{UInt64,Int64}
    positions::Vector{Position}
    positionHashTable::Dict{UInt64,Int64}
    instructions::Vector{Instruction}
    instructionHashTable::Dict{UInt64,Int64}
    pointer::Vector{Int64}
    function CircuitConstructor(geometry::Geometry)
        G = typeof(geometry)
        operations = Operation[]
        operationHashTable = Dict{UInt64,Int64}()
        positions = Position[]
        positionHashTable = Dict{UInt64,Int64}()
        instructions = Instruction[]
        instructionHashTable = Dict{UInt64,Int64}()
        pointer = Int64[]
        new{G}(geometry,operations,operationHashTable,positions,positionHashTable,instructions,instructionHashTable,pointer)
    end
end

# Circuit optimized for interation (but static)
"""
    Circuit{Ops<:Tuple}
A circuit optimized for iteration. The operations are stored in a tuple. The operations are stored in a tuple to allow for efficient iteration.
"""
struct Circuit{Ops<:Tuple}
    operations::Ops
    positions::Vector{Position}
    instructions::Vector{Instruction}
    pointer::Vector{Int64}
    function Circuit(circuit::CircuitConstructor)
        operations = (circuit.operations...,)
        Ops = typeof(operations)
        positions = circuit.positions
        instructions = circuit.instructions
        pointer = circuit.pointer
        new{Ops}(operations, positions, instructions, pointer)
    end
end
function Base.:(==)(pos1::Position,pos2::Position)
    return all(pos1.positions .== pos2.positions) && pos1.weights == pos2.weights
end
function Base.:(==)(ins1::Instruction,ins2::Instruction)
    return all(ins1.positions .== ins2.positions) && all(ins1.operations .== ins2.operations) && ins1.weights == ins2.weights
end
function Base.hash(position::Position)
    return hash((position.positions,position.weights))
end
function Base.hash(instruction::Instruction)
    return hash((instruction.operations,instruction.positions,instruction.weights))
end

function Base.in(operation::Operation, circuit::CircuitConstructor)
    return haskey(circuit.operationHashTable, hash(operation))
end
function Base.in(position::Position, circuit::CircuitConstructor)
    return haskey(circuit.positionHashTable, hash(position))
end
function Base.in(instruction::Instruction, circuit::CircuitConstructor)
    return haskey(circuit.instructionHashTable, hash(instruction))
end
function Base.getindex(circuit::CircuitConstructor, operation::Operation)
    return circuit.operationHashTable[hash(operation)]
end
function Base.getindex(circuit::CircuitConstructor, position::Position)
    return circuit.positionHashTable[hash(position)]
end
function Base.getindex(circuit::CircuitConstructor, instruction::Instruction)
    return circuit.instructionHashTable[hash(instruction)]
end

function Base.push!(circuit::CircuitConstructor, operation::Operation)
    if operation in circuit
        return circuit[operation]
    else
        push!(circuit.operations, operation)
        index = length(circuit.operations)
        circuit.operationHashTable[hash(operation)] = index
        return index
    end
    return 0
end
function Base.push!(circuit::CircuitConstructor, position::Position)
    if position in circuit
        return circuit[position]
    else
        push!(circuit.positions, position)
        index = length(circuit.positions)
        circuit.positionHashTable[hash(position)] = index
        return index
    end
    return 0
end
function Base.push!(circuit::CircuitConstructor, instruction::Instruction)
    if instruction in circuit
        return circuit[instruction]
    else
        push!(circuit.instructions, instruction)
        index = length(circuit.instructions)
        circuit.instructionHashTable[hash(instruction)] = index
        return index
    end
    return 0
end

function apply!(circuit::CircuitConstructor, operation::Operation, position::Vararg{Integer})
    operationIndex = push!(circuit, operation)
    pos = Position(position...)
    positionIndex = push!(circuit, pos)
    instruction = Instruction(operationIndex, positionIndex)
    instructionIndex = push!(circuit, instruction)
    push!(circuit.pointer, instructionIndex)
end

function apply!(circuit::CircuitConstructor, operations::Vararg{Tuple{<:Operation, <:Real, Matrix{<:Integer}, Vector{<:Real}}})
    sum([operation[2] for operation in operations]) ≈ 1.0 || throw(ArgumentError("Probabilities must add up to 1."))
    all([sum(operation[4]) for operation in operations] .≈ 1.0) || throw(ArgumentError("Probabilities must add up to 1."))

    operationIndecies = [push!(circuit, operation[1]) for operation in operations]
    positions = [Position(operation[3],operation[4]) for operation in operations]
    positionIndecies = [push!(circuit, pos) for pos in positions]
    probabilities = [operation[2] for operation in operations]
    instruction = Instruction(operationIndecies, positionIndecies, probabilities)
    instructionIndex = push!(circuit, instruction)
    push!(circuit.pointer, instructionIndex)
end

function apply!(circuit::CircuitConstructor, operations::Vector, probabilities::Vector, positions::Vector, positionProbabilities::Vector)
    sum(probabilities) ≈ 1.0 || throw(ArgumentError("Probabilities must add up to 1."))
    all([sum(prob) for prob in positionProbabilities] .≈ 1.0) || throw(ArgumentError("Probabilities must add up to 1."))

    operationIndecies = [push!(circuit, operation) for operation in operations]
    poses = [Position(position,prob) for (position,prob) in zip(positions,positionProbabilities)]
    positionIndecies = [push!(circuit, pos) for pos in poses]
    instruction = Instruction(operationIndecies, positionIndecies, probabilities)
    instructionIndex = push!(circuit, instruction)
    push!(circuit.pointer, instructionIndex)
end

function apply!(circuit::CircuitConstructor, index::Integer)
    push!(circuit.pointer, index)
end

function compile(circuit::CircuitConstructor)
    return Circuit(circuit)
end

function execute(::Circuit, backend::Backend; verbose::Bool=true)
    throw(ArgumentError("Backend $(typeof(backend)) not supported"))
end
function Base.getindex(circuit::Circuit, i::Integer)
    instruction = circuit.instructions[circuit.pointer[i]]
    index = StatsBase.sample(instruction.weights)
    position = circuit.positions[instruction.positions[index]]
    posIndex = StatsBase.sample(position.weights)
    return instruction.operations[index], @view position.positions[:, posIndex]
end
function Base.getindex(circuit::CircuitConstructor, i::Integer)
    instruction = circuit.instructions[circuit.pointer[i]]
    index = StatsBase.sample(instruction.weights)
    position = circuit.positions[instruction.positions[index]]
    posIndex = StatsBase.sample(position.weights)
    return circuit.operations[instruction.operations[index]], @view position.positions[:,posIndex]
end

function depth(circuit::Circuit)
    return length(circuit.pointer)
end
function depth(circuit::CircuitConstructor)
    return length(circuit.pointer)
end

function Base.show(io::IO, circuit::CircuitConstructor)
    for i in 1:depth(circuit)
        instruction = circuit.instructions[circuit.pointer[i]]
        operationsIndeces = instruction.operations
        probs = instruction.weights
        for (prob, j) in zip(probs, operationsIndeces)
            operation = circuit.operations[j]
            println(io, prob * 100, "%: ", operation)
        end

    end

end

@generated function getOperation(circuit::Circuit, ::Val{i}) where {i}
    # Generate code that returns the i-th element from the tuple of operations.
    return :(circuit.operations[$i])
end

@generated function getOperationByIndex(circuit::Circuit{Ops}, i::Integer) where {Ops}
    n = length(Ops.parameters)  # Get the length of the tuple from its type parameters.
    branches = Vector{Expr}(undef, n + 1)
    for j in 1:n
        # Generate code that checks if i equals j and if so, returns the j-th operation.
        branches[j] = quote
            if i == $(j)
                return getOperation(circuit, Val($(j)))
            end
        end
    end
    # If no branch matched, produce an error.
    branches[n+1] = :(error("Index out of bounds: ", i))
    return Expr(:block, branches...)
end
