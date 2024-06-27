abstract type Lattice end
function getBonds(lattice::Lattice)
    throw(ArgumentError("getBonds not implemented for $(typeof(lattice)). Please implement this method for your custom lattice."))
end



struct ChainLattice{T} <: Lattice where {T<:Integer}
    length::T # the length of the chain / number of non auxiliary qubits
    physicalMap::Vector{T} # the mapping to the physical qubits indices on a device
    function ChainLattice(length::Integer)
        length > 0 || throw(ArgumentError("length must be positive"))
        T = typeof(length)
        physicalMap = fill(-1, length)
        return new{T}(length, physicalMap)
    end
end
getBonds(chain::ChainLattice) = [(i, i + 1) for i in 1:chain.length-1]


struct SquareLattice{T} <: Lattice where {T<:Integer}
    sizeX::T # the linear size of the lattice in x direction
    sizeY::T # the linear size of the lattice in y direction
    length::T # the length of the lattice
    physicalMap::Vector{T} # the mapping to the physical qubits indices on a device
    function SquareLattice(length::Integer)
        length > 0 || throw(ArgumentError("length must be positive"))
        T = typeof(length)
        size = isqrt(length)
        physicalMap = fill(-1, length)
        return new{T}(size, size, length, physicalMap)
    end
    function SquareLattice(sizeX::Integer, sizeY::Integer)
        sizeX > 0 || throw(ArgumentError("sizeX must be positive"))
        sizeY > 0 || throw(ArgumentError("sizeY must be positive"))
        T = typeof(sizeX)
        length = sizeX * sizeY
        physicalMap = fill(-1, length)
        return new{T}(sizeX, sizeY, length, physicalMap)
    end
end
Base.size(lattice::SquareLattice) = (lattice.sizeX, lattice.sizeY)
two_index_to_one(i::Integer, j::Integer, size::Integer) = (i - 1) * size + j
one_index_to_two(index::Integer, size::Integer) = (div(index, size) + 1, mod(index, size) + 1)
function getBonds(lattice::SquareLattice)
    bonds = Tuple{Int,Int}[]
    for i in 1:lattice.sizeX
        for j in 1:lattice.sizeY
            if i < lattice.sizeX
                push!(bonds, (two_index_to_one(i, j, lattice.sizeY), two_index_to_one(i + 1, j, lattice.sizeY)))
            end
            if j < lattice.sizeY
                push!(bonds, (two_index_to_one(i, j, lattice.sizeY), two_index_to_one(i, j + 1, lattice.sizeY)))
            end
        end
    end
    return bonds
end



function Base.show(io::IO, lattice::Lattice)
    println(io, "$(typeof(lattice)) with:")
    println(io, "length: ", lattice.length)
    allequal([lattice.physicalMap[i] == -1 for i in 1:lattice.length]) ? println(io, "No mapping to chip defined") : println(io, "physicalMap: ", lattice.physicalMap)
end

function Base.show(io::IO, lattice::SquareLattice)
    println(io, "$(typeof(lattice)) with:")
    println(io, "length: ", lattice.length, " (", lattice.sizeX, "x", lattice.sizeY, ")")
    allequal([lattice.physicalMap[i] == -1 for i in 1:lattice.length]) ? println(io, "No mapping to chip defined") : println(io, "physicalMap: ", lattice.physicalMap)
end

function Base.length(lattice::Lattice)
    return lattice.length
end
