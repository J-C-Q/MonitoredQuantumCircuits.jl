abstract type Lattice end
struct Chain{T} <: Lattice where {T<:Integer}
    length::T # the length of the chain / number of non auxiliary qubits
    physicalMap::Vector{T} # the mapping to the physical qubits indeces on a device
    operations::Vector{Operation} # the (unique) operations on the chain
    operationPositions::Vector{Tuple{T,T}} # the position where the operations get applied on the chain
    operationPointers::Vector{T} # the pointer to which operation gets applied at the position

    function Chain(length::Integer)
        length > 0 || throw(ArgumentError("length must be positive"))
        T = typeof(length)
        physicalMap = fill(-1, length)
        operations = Operation[]
        operationPositions = Tuple{T,T}[]
        operationPointers = T[]
        return new{T}(length, physicalMap, operations, operationPositions, operationPointers)
    end
end
EmptyChain(length::Integer) = Chain(length)


struct Square{T} <: Lattice where {T<:Integer}
    sizeX::T # the linear size of the lattice in x direction
    sizeY::T # the linear size of the lattice in y direction
    length::T # the length of the lattice
    physicalMap::Vector{T} # the mapping to the physical qubits indeces on a device
    operations::Vector{Operation} # the (unique) operations on the lattice
    operationPositions::Vector{Tuple{T,T}} # the position where the operations get applied on the lattice
    operationPointers::Vector{T} # the pointer to which operation gets applied at the position
    function Square(length::Integer)
        length > 0 || throw(ArgumentError("length must be positive"))
        T = typeof(length)
        size = isqrt(length)
        physicalMap = fill(-1, length)
        operations = Operation[]
        operationPositions = Tuple{T,T}[]
        operationPointers = T[]
        return new{T}(size, size, length, physicalMap, operations, operationPositions, operationPointers)
    end
end
Base.size(lattice::Square) = (lattice.sizeX, lattice.sizeY)
two_index_to_one(i::Integer, j::Integer, size::Integer) = (i - 1) * size + j
one_index_to_two(index::Integer, size::Integer) = (div(index, size) + 1, mod(index, size) + 1)

EmptySquare(length::Integer) = Square(length)



function Base.show(io::IO, lattice::Lattice)
    println(io, "$(typeof(lattice)) with:")
    println(io, "length: ", lattice.length)
    allequal([lattice.physicalMap[i] == -1 for i in 1:lattice.length]) ? println(io, "No mapping to chip defined") : println(io, "physicalMap: ", lattice.physicalMap)
    if isempty(lattice.operationPointers)
        println(io, "No operations defined")
    else
        println(io, "operations: ")
        for (i, ptr) in enumerate(lattice.operationPointers)
            println(io, "  ", lattice.operations[ptr], " at ", lattice.operationPositions[i])
        end
    end
end

function Base.show(io::IO, lattice::Square)
    println(io, "$(typeof(lattice)) with:")
    println(io, "length: ", lattice.length, " (", lattice.sizeX, "x", lattice.sizeY, ")")
    allequal([lattice.physicalMap[i] == -1 for i in 1:lattice.length]) ? println(io, "No mapping to chip defined") : println(io, "physicalMap: ", lattice.physicalMap)
    if isempty(lattice.operationPointers)
        println(io, "No operations defined")
    else
        println(io, "operations: ")
        for (i, ptr) in enumerate(lattice.operationPointers)
            println(io, "  ", lattice.operations[ptr], " at ", lattice.operationPositions[i])
        end
    end
end

function Base.push!(lattice::Lattice, operation::Operation, position...) where {T<:Integer}
    if operation in lattice.operations
        index = findfirst([op == operation for op in lattice.operations])
    else
        push!(lattice.operations, operation)
        index = length(lattice.operations)
    end
    push!(lattice.operationPositions, position)
    push!(lattice.operationPointers, index)
    return lattice
end
