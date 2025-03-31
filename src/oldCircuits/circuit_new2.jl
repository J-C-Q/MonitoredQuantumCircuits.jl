using AllocCheck
# Information needed to describe the circuit
# 1. Each operation is a tupe
# (typeOffset, typeOptions, typeProbabilityOffset, positionOffset, positionLengthOffset, positionOptionsOffset,positionProbabilitieOffset, floatParameterOffset, floatParameterLengthOffset, intParameterOffset,intParameterLengthOffset,hash)
const typeEnum = [X, Y, Z, XX, YY, ZZ, NPauli]

const typeEnumReverse = Dict{DataType,Int64}(op => i for (i, op) in enumerate(typeEnum))
struct PointerObject
    typeOffset::UInt64
    typeOptions::UInt64
    typeProbabilityOffset::UInt64
    positionOffset::UInt64
    positionLengthOffset::UInt64
    positionOptionsOffset::UInt64
    positionProbabilityOffset::UInt64
    floatParameterOffset::UInt64
    floatParameterLengthOffset::UInt64
    intParameterOffset::UInt64
    intParameterLengthOffset::UInt64
    hash::UInt64
    randomness::UInt64
end
struct Circuit2{T<:Geometry} <: QuantumCircuit
    geometry::T
    pointerMemory::Vector{PointerObject}
    typeMemory::Vector{Int64}
    typeProbabilityMemory::Vector{Weights{Float64,Float64,Vector{Float64}}}
    positionMemory::Vector{Int64}
    positionLengthMemory::Vector{Int64}
    positionOptionsMemory::Vector{Int64}
    positionProbabilityMemory::Vector{Weights{Float64,Float64,Vector{Float64}}}
    floatParameterMemory::Vector{Float64}
    floatParameterLengthMemory::Vector{Int64}
    intParameterMemory::Vector{Int64}
    intParameterLengthMemory::Vector{Int64}

    function Circuit2(geometry::Geometry)
        new{typeof(geometry)}(
            geometry,
            PointerObject[],
            Int64[],
            Float64[],
            Int64[],
            Int64[],
            Int64[],
            Float64[],
            Float64[],
            Int64[],
            Int64[],
            Int64[]
        )
    end
end

function typeMemoryLength(circuit::Circuit2)
    length(circuit.typeMemory)
end
function positionMemoryLength(circuit::Circuit2)
    length(circuit.positionMemory)
end
function positionLengthMemoryLength(circuit::Circuit2)
    length(circuit.positionLengthMemory)
end
function positionOptionsMemoryLength(circuit::Circuit2)
    length(circuit.positionOptionsMemory)
end
function floatParameterMemoryLength(circuit::Circuit2)
    length(circuit.floatParameterMemory)
end
function floatParameterLengthMemoryLength(circuit::Circuit2)
    length(circuit.floatParameterLengthMemory)
end
function intParameterMemoryLength(circuit::Circuit2)
    length(circuit.intParameterMemory)
end
function intParameterLengthMemoryLength(circuit::Circuit2)
    length(circuit.intParameterLengthMemory)
end

function operationType(circuit::Circuit2, i::Integer)
    pointer = circuit.pointerMemory[i]
    return @view circuit.typeMemory[pointer.typeOffset:pointer.typeOffset+pointer.typeOptions-1]
end

function Base.length(circuit::Circuit2)
    length(circuit.pointerMemory)
end
function depth(circuit::Circuit2)
    return length(circuit)
end
function isRandom(circuit::Circuit2)
    !all([p.typeOptions == 1 && circuit.positionOptionsMemory[p.positionOptionsOffset] == 1 for p in circuit.pointerMemory])
end
function isRandom(circuit::Circuit2, operation::Int64)
    p = circuit.pointerMemory[operation]
    return !(p.typeOptions == 1 && circuit.positionOptionsMemory[p.positionOptionsOffset] == 1)
end
function hasRandomType(circuit::Circuit2, operation::Int64)
    p = circuit.pointerMemory[operation]
    return p.typeOptions != 1
end
function hasRandomPosition(circuit::Circuit2, operation::Int64; suboperation=1)
    p = circuit.pointerMemory[operation]
    suboperation <= p.typeOptions || throw(ArgumentError("invalid suboperation"))
    positionOptions = circuit.positionOptionsMemory[p.positionOptionsOffset+suboperation-1]
    return positionOptions != 1
end
function nSuboperations(circuit::Circuit2, operation::Int64)
    p = circuit.pointerMemory[operation]
    return p.typeOptions
end
function nPositions(circuit::Circuit2, operation::Int64; suboperation=1)
    p = circuit.pointerMemory[operation]
    suboperation <= p.typeOptions || throw(ArgumentError("invalid suboperation"))
    positionOptions = circuit.positionOptionsMemory[p.positionOptionsOffset+suboperation-1]
    return positionOptions
end
function nQubits(circuit::Circuit2, operation::Int64; suboperation=1)
    p = circuit.pointerMemory[operation]
    suboperation <= p.typeOptions || throw(ArgumentError("invalid suboperation"))
    qubits = circuit.positionLengthMemory[p.positionLengthOffset+suboperation-1]
    return qubits
end
function nQubits(circuit::Circuit2)
    nQubits(circuit.geometry)
end

function Base.show(io::IO, c::Circuit2)
    for p in c.pointerMemory
        if p.typeOptions == 1
            if c.positionOptionsMemory[p.positionOptionsOffset] == 1
                println(io, typeEnumReverse[c.typeMemory[p.typeOffset]], " at ", c.positionMemory[p.positionOffset:(p.positionOffset+c.positionLengthMemory[p.positionLengthOffset]-1)])
            else
                println(io, typeEnumReverse[c.typeMemory[p.typeOffset]], " at ")
                if c.positionOptionsMemory[p.positionOptionsOffset] < 5
                    for i in 1:c.positionOptionsMemory[p.positionOptionsOffset]
                        println(io, c.positionMemory[(p.positionOffset+(i-1)*c.positionLengthMemory[p.positionLengthOffset]):(p.positionOffset+i*c.positionLengthMemory[p.positionLengthOffset]-1)])
                    end
                else
                    show(io,)

                end
                println(io, "operation with many possible positions")
            end
        else
            println(io, "many possible operations")
        end
    end

end

function apply!(circuit::Circuit2, operation::Operation, position::Vararg{Int64})
    _checkInBounds(circuit, operation, position...)
    id = hash([operation, position])
    i = findfirst(p -> p.hash == id, circuit.pointerMemory)

    if isnothing(i)
        typeOffset = UInt64(typeMemoryLength(circuit) + 1)
        typeOptions = UInt64(1)
        typeProbabilityOffset = UInt64(1)
        positionOffset = UInt64(positionMemoryLength(circuit) + 1)
        positionLengthOffset = UInt64(positionLengthMemoryLength(circuit) + 1)
        positionOptionsOffset = UInt64(positionOptionsMemoryLength(circuit) + 1)
        positionProbabilityOffset = UInt64(1)

        floatParameter, intParameter = getParameter(operation)

        floatParameterOffset = UInt64(length(floatParameter) == 0 ? 1 : floatParameterMemoryLength(circuit) + 1)
        intParameterOffset = UInt64(length(intParameter) == 0 ? 1 : intParameterMemoryLength(circuit) + 1)
        floatParameterLengthOffset = UInt64(floatParameterLengthMemoryLength(circuit) + 1)
        intParameterLengthOffset = UInt64(intParameterLengthMemoryLength(circuit) + 1)
        push!(circuit.floatParameterLengthMemory, length(floatParameter))
        push!(circuit.intParameterLengthMemory, length(intParameter))
        append!(circuit.floatParameterMemory, floatParameter)
        append!(circuit.intParameterMemory, intParameter)

        push!(circuit.typeMemory, typeEnumReverse[typeof(operation)])
        append!(circuit.positionMemory, position)
        push!(circuit.positionLengthMemory, length(position))
        push!(circuit.positionOptionsMemory, 1)

        pointers = PointerObject(
            typeOffset,
            typeOptions,
            typeProbabilityOffset,
            positionOffset,
            positionLengthOffset,
            positionOptionsOffset,
            positionProbabilityOffset,
            floatParameterOffset,
            floatParameterLengthOffset,
            intParameterOffset,
            intParameterLengthOffset,
            id,
            0)
        push!(circuit.pointerMemory, pointers)
    else
        push!(circuit.pointerMemory, circuit.pointerMemory[i])
    end
    return circuit
end
function apply!(circuit::Circuit2, operation::Operation, position::Vector{Int64})
    apply!(circuit, operation, position...)
end
function apply!(circuit::Circuit2, operation::Operation, position::NTuple{N,Int64}) where {N}
    apply!(circuit, operation, position...)
end


function apply!(
    circuit::Circuit2,
    operations::Vector{Operation},
    probabilities::Vector{Float64},
    positions::Vector{Vector{Vector{Int64}}},
    positionProbabilities::Vector{Vector{Float64}}
)
    # TODO check inbound and prob = 1

    id = hash([operations, probabilities, positions, positionProbabilities])
    i = findfirst(p -> p.hash == id, circuit.pointerMemory)
    if isnothing(i)
        typeOffset = UInt64(typeMemoryLength(circuit) + 1)
        typeOptions = UInt64(length(operations))
        typeProbabilityOffset = UInt64(length(operations) == 1 ? 1 : length(circuit.typeProbabilityMemory) + 1)
        positionOffset = UInt64(positionMemoryLength(circuit) + 1)
        positionLengthOffset = UInt64(positionLengthMemoryLength(circuit) + 1)
        positionOptionsOffset = UInt64(positionOptionsMemoryLength(circuit) + 1)
        positionProbabilityOffset = UInt64(all(p -> length(p) == 0, positionProbabilities) ? 1 : length(circuit.positionProbabilityMemory) + 1)

        if all(p -> !hasParameter(typeof(p), Int64), operations)
            intParameterOffset = UInt64(1)
        else
            intParameterOffset = UInt64(intParameterMemoryLength(circuit) + 1)
        end
        if all(p -> !hasParameter(typeof(p), Float64), operations)
            floatParameterOffset = UInt64(1)
        else
            floatParameterOffset = UInt64(floatParameterMemoryLength(circuit) + 1)
        end
        floatParameterLengthOffset = UInt64(floatParameterLengthMemoryLength(circuit) + 1)
        intParameterLengthOffset = UInt64(intParameterLengthMemoryLength(circuit) + 1)
        for operation in operations
            floatParameter, intParameter = getParameter(operation)
            push!(circuit.floatParameterLengthMemory, length(floatParameter))
            push!(circuit.intParameterLengthMemory, length(intParameter))
            append!(circuit.floatParameterMemory, floatParameter)
            append!(circuit.intParameterMemory, intParameter)
        end

        append!(circuit.typeMemory, [typeEnumReverse[type] for type in typeof.(operations)])
        push!(circuit.typeProbabilityMemory, Weights(probabilities))
        for positionOptions in positions
            push!(circuit.positionOptionsMemory, length(positionOptions))
            push!(circuit.positionLengthMemory, length(positionOptions[1]))
            for position in positionOptions
                append!(circuit.positionMemory, position)
            end
        end
        for probability in positionProbabilities
            push!(circuit.positionProbabilityMemory, Weights(probability))
        end



        pointers = PointerObject(
            typeOffset,
            typeOptions,
            typeProbabilityOffset,
            positionOffset,
            positionLengthOffset,
            positionOptionsOffset,
            positionProbabilityOffset,
            floatParameterOffset,
            floatParameterLengthOffset,
            intParameterOffset,
            intParameterLengthOffset,
            id,
            3)
        push!(circuit.pointerMemory, pointers)
    else
        push!(circuit.pointerMemory, circuit.pointerMemory[i])
    end
    return circuit
end

function apply!(circuit::Circuit2, operation::Integer)
    push!(circuit.pointerMemory, circuit.pointerMemory[operation])
    return circuit
end





# function apply!(circuit::Circuit, operation::Operation, position::Vararg{T}) where {T<:Integer}
#     _checkInBounds(circuit, operation, position...)
#     if length(circuit.operations) < circuit.depth[1]
#         push!(circuit.operations, operation)
#         push!(circuit.positions, position)
#     else
#         circuit.operations[circuit.depth[1]] = operation
#         circuit.positions[circuit.depth[1]] = position
#     end
#     circuit.depth[1] += 1
#     return nothing
# end

# function reset!(circuit::Circuit)
#     circuit.depth[1] = 1
# end

# function hard_reset!(circuit::Circuit)
#     circuit.operations = Operation[]
#     circuit.positions = Tuple{Int,Vararg{Int}}[]
#     circuit.depth[1] = 1
# end

# function depth(circuit::Circuit)
#     return circuit.depth[1] - 1
# end

function _checkInBounds(circuit::Circuit2, operation::Operation, position::Vararg{Integer})
    nQubits(operation) == length(position) || throw(ArgumentError("The number of qubits in the operation does not match the number of qubits in the position."))
    all(1 .<= position .<= nQubits(circuit.geometry)) || throw(ArgumentError("The position is out of bounds."))
end

# function execute(::Circuit, backend::Backend; verbose::Bool=true)
#     throw(ArgumentError("Backend $(typeof(backend)) not supported"))
# end

# function nQubits(circuit::Circuit)
#     return nQubits(circuit.geometry)
# end

# function nMeasurement(circuit::Circuit)
#     sum = 0
#     for i in 1:depth(circuit)
#         if typeof(circuit.operations[i]) <: MeasurementOperation
#             sum += 1
#         end
#     end
#     return sum
# end








# struct RandomCircuit{T<:Geometry} <: QuantumCircuit
#     lattice::T
#     operations::Vector{Operation}
#     time_probability::Vector{Float64}
#     positions::Vector{Vector{Tuple{Int,Vararg{Int}}}}
#     position_probability::Vector{Vector{Float64}}
#     function RandomCircuit(
#         geometry::Geometry,
#         gates::Vector{Operation},
#         probabilities::Vector{Float64},
#         positions::Vector{Vector{Tuple{Int,Vararg{Int}}}})

#         new{typeof(geometry)}(geometry,
#             gates,
#             probabilities,
#             positions,
#             [fill(1 / length(p)) for p in positions])
#     end
# end


# struct FloquetCircuit{T<:Geometry} <: QuantumCircuit

# end
