abstract type Lattice end
function getBonds(lattice::Lattice)
    bonds = collect(edges(lattice.graph))
    return [(src(e), dst(e)) for e in bonds]
end

function Base.length(lattice::Lattice)
    return nv(lattice.graph)
end

function Base.show(io::IO, lattice::Lattice)
    print(io, "$(typeof(lattice)) with ", length(lattice), " sites and ")
    bonds = getBonds(lattice)
    if length(bonds) == 0
        print(io, "no bonds defined")
        println(io)
    elseif length(bonds) > 20
        print(io, "$(length(bonds)) bonds")
        println(io)
    else
        println(io, "bonds:")
        for (i, bond) in enumerate(bonds)
            println(io, bond)
        end
    end
    allequal([lattice.physicalMap[i] == -1 for i in 1:length(lattice)]) ? println(io, "No mapping to chip defined") : println(io, "physicalMap: ", lattice.physicalMap)
    visualize(io, lattice)
end


include("lattices/heavyChainLattice.jl")
include("lattices/heavySquareLattice.jl")
include("lattices/heavyHexagonLattice.jl")

function visualize(io::IO, lattice::Lattice)
    return nothing
end


# struct SquareLattice{T} <: Lattice where {T<:Integer}
#     sizeX::T # the linear size of the lattice in x direction
#     sizeY::T # the linear size of the lattice in y direction
#     length::T # the length of the lattice
#     graph::Graph
#     physicalMap::Vector{T} # the mapping to the physical qubits indices on a device
#     function SquareLattice(length::Integer)
#         length > 0 || throw(ArgumentError("length must be positive"))
#         T = typeof(length)
#         size = isqrt(length)
#         physicalMap = fill(-1, length)
#         return new{T}(size, size, length, physicalMap)
#     end
#     function SquareLattice(sizeX::Integer, sizeY::Integer)
#         sizeX > 0 || throw(ArgumentError("sizeX must be positive"))
#         sizeY > 0 || throw(ArgumentError("sizeY must be positive"))
#         T = typeof(sizeX)
#         length = sizeX * sizeY
#         physicalMap = fill(-1, length)
#         return new{T}(sizeX, sizeY, length, physicalMap)
#     end
# end
# Base.size(lattice::SquareLattice) = (lattice.sizeX, lattice.sizeY)
# two_index_to_one(i::Integer, j::Integer, size::Integer) = (i - 1) * size + j
# one_index_to_two(index::Integer, size::Integer) = (div(index, size) + 1, mod(index, size) + 1)
# function getBonds(lattice::SquareLattice)
#     bonds = Tuple{Int,Int}[]
#     for i in 1:lattice.sizeX
#         for j in 1:lattice.sizeY
#             if i < lattice.sizeX
#                 push!(bonds, (two_index_to_one(i, j, lattice.sizeY), two_index_to_one(i + 1, j, lattice.sizeY)))
#             end
#             if j < lattice.sizeY
#                 push!(bonds, (two_index_to_one(i, j, lattice.sizeY), two_index_to_one(i, j + 1, lattice.sizeY)))
#             end
#         end
#     end
#     return bonds
# end
