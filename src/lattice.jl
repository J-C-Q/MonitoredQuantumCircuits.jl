abstract type Lattice end
struct Chain{T} <: Lattice where {T<:Integer}
    length::T # the length of the chain / number of non auxiliary qubits
    physicalMap::Vector{T} # the mapping to the physical qubits indices on a device
    function Chain(length::Integer)
        length > 0 || throw(ArgumentError("length must be positive"))
        T = typeof(length)
        physicalMap = fill(-1, length)
        return new{T}(length, physicalMap)
    end
end
EmptyChain(length::Integer) = Chain(length)
getBonds(chain::Chain) = [(i, i + 1) for i in 1:chain.length-1]


struct Square{T} <: Lattice where {T<:Integer}
    sizeX::T # the linear size of the lattice in x direction
    sizeY::T # the linear size of the lattice in y direction
    length::T # the length of the lattice
    physicalMap::Vector{T} # the mapping to the physical qubits indices on a device
    function Square(length::Integer)
        length > 0 || throw(ArgumentError("length must be positive"))
        T = typeof(length)
        size = isqrt(length)
        physicalMap = fill(-1, length)
        return new{T}(size, size, length, physicalMap)
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
end

function Base.show(io::IO, lattice::Square)
    println(io, "$(typeof(lattice)) with:")
    println(io, "length: ", lattice.length, " (", lattice.sizeX, "x", lattice.sizeY, ")")
    allequal([lattice.physicalMap[i] == -1 for i in 1:lattice.length]) ? println(io, "No mapping to chip defined") : println(io, "physicalMap: ", lattice.physicalMap)
end

function Base.length(lattice::Lattice)
    return lattice.length
end
