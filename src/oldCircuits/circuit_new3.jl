


using StatsBase

struct OperationBlock{T<:Operation}
    operation::T
    possiblePositions::Matrix{Int64}
    positionWeights::StatsBase.Weights{Float64,Float64,Vector{Float64}}
    function OperationBlock(operation::Operation, position::Vararg{Integer})
        possiblePositions = zeros(Int64, length(position), 1)
        possiblePositions[:, 1] .= position
        positionWeights = StatsBase.Weights([1.0])
        new{typeof(operation)}(operation, possiblePositions, positionWeights)
    end
    function OperationBlock(
        operation::Operation,
        possiblePositions::Matrix{Int64},
        probabilities::Vector{Float64})

        positionWeights = StatsBase.Weights(probabilities)
        new{typeof(operation)}(operation, possiblePositions, positionWeights)
    end
end

#! Update when adding a new operation
const OperationUnion = Union{
    OperationBlock{X},
    OperationBlock{Y},
    OperationBlock{Z},
    OperationBlock{XX},
    OperationBlock{YY},
    OperationBlock{ZZ},
    OperationBlock{NPauli}
}



struct Instruction
    operationIndecies::Vector{Int64}
    weights::StatsBase.Weights{Float64,Float64,Vector{Float64}}
    function Instruction(index::Int64)
        operationIndecies = Int64[index]
        weights = StatsBase.Weights([1.0])
        return new(operationIndecies, weights)
    end
end



struct Circuit3 <: QuantumCircuit
    operations::Vector{Union{OperationBlock{X},
        OperationBlock{Y},
        OperationBlock{Z},
        OperationBlock{XX},
        OperationBlock{YY},
        OperationBlock{ZZ},
        OperationBlock{NPauli}}}
    operationHashTable::Dict{UInt64,Int64}
    instructions::Vector{Instruction}
    instructionHashTable::Dict{UInt64,Int64}
    pointer::Vector{Int64}

    function Circuit3()
        new(OperationUnion[],
            Dict{UInt64,Int64}(),
            Instruction[],
            Dict{UInt64,Int64}(),
            Int64[])
    end
end

function Base.in(operationBlock::OperationBlock, circuit::Circuit3)
    return haskey(circuit.operationHashTable, hash(operationBlock))
end
function Base.in(instruction::Instruction, circuit::Circuit3)
    return haskey(circuit.instructionHashTable, hash(instruction))
end

function Base.getindex(circuit::Circuit3, operationBlock::OperationBlock)
    return circuit.operationHashTable[hash(operationBlock)]
end
function Base.getindex(circuit::Circuit3, instruction::Instruction)
    return circuit.instructionHashTable[hash(instruction)]
end

function Base.push!(circuit::Circuit3, operationBlock::OperationBlock)
    if operationBlock in circuit
        return circuit[operationBlock]
    else
        push!(circuit.operations, operationBlock)
        index = length(circuit.operations)
        circuit.operationHashTable[hash(operationBlock)] = index
        return index
    end
end
function Base.push!(circuit::Circuit3, instruction::Instruction)
    if instruction in circuit
        return circuit[instruction]
    else
        push!(circuit.instructions, instruction)
        index = length(circuit.instructions)
        circuit.instructionHashTable[hash(instruction)] = index
        return index
    end
end
function Base.push!(circuit::Circuit3, pointer::Int64)
    push!(circuit.pointer, pointer)
end

function apply!(circuit::Circuit3, operation::Operation, position::Vararg{Int64})
    operationBlock = OperationBlock(operation, position...)
    operationIndex = push!(circuit, operationBlock)
    instruction = Instruction(operationIndex)
    instructionIndex = push!(circuit, instruction)
    push!(circuit.pointer, instructionIndex)
end

function apply!(circuit::Circuit3, operations::Vector, probabilities::Vector{Float64})

end


function depth(circuit::Circuit3)
    return length(circuit.pointer)
end

function Base.eachindex(circuit::Circuit3)
    return 1:depth(circuit)
end
