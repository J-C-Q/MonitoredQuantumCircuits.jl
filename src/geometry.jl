
"""
    Geometry

Abstract type for the geometry of the qubits.
"""
abstract type Geometry end
abstract type BoundaryCondition end
abstract type Periodic <: BoundaryCondition end
abstract type Open <: BoundaryCondition end

function getBonds(geometry::Geometry)
    bonds = collect(edges(geometry.graph))
    return [(src(e), dst(e)) for e in bonds]
end

function Base.length(geometry::Geometry)
    return nv(geometry.graph)
end

"""
    nQubits(geometry::Geometry)

Return the number of qubits in the geometry.
"""
function nQubits(geometry::Geometry)::Int64
    return nv(geometry.graph)
end

function nBonds(geometry::Geometry)
    return ne(geometry.graph)
end

# function qubits(geometry::Geometry)
#     return reshape(collect(1:nQubits(geometry)), 1, nQubits(geometry))
# end

function Base.show(io::IO, geometry::Geometry)
    print(io, "$(typeof(geometry)) with ", length(geometry), " sites and ")
    bonds = getBonds(geometry)
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
    # nv(geometry.graph) <= 100 && visualize(io, geometry)
end

function to_linear(geometry::Geometry, ::NTuple{d,Int64}) where {d}
    throw(ArgumentError("No function defined to convert $d dimensional grid index to linear index for a geometry of type $(typeof(geometry))"))
end




function to_grid(geometry::Geometry, ::Int64)
    throw(ArgumentError("No function defined to convert linear index to grid indicies for a geometry of type $(typeof(geometry))"))
end

function neighbor(geometry::Geometry, i::Int64; direction::Symbol)
    throw(ArgumentError("No function defined to get the neighbor of $i in direction $direction for a geometry of type $(typeof(geometry))"))
end

function drawGeometry(geometry::Geometry; kwargs...)
    throw(ArgumentError("No function defined to draw geometry of type $(typeof(geometry)). Load Makie.jl to visualize geometries."))
end


struct Bond{T<:Integer}
    qubit1::T
    qubit2::T
    function Bond(q1::T, q2::T) where {T<:Integer}
        return q1 ≤ q2 ? new{T}(q1, q2) : new{T}(q2, q1)
    end
end
function Base.show(io::IO, bond::Bond)
    print(io, "$(bond.qubit1) ⟷ $(bond.qubit2)")
end
# --- make Bond iterable of length 2 ---
function Base.iterate(b::Bond{T}, state::Int=1) where T
    state == 1 && return (b.qubit1, 2)
    state == 2 && return (b.qubit2, 3)
    return nothing
end
Base.length(::Bond) = 2
Base.eltype(::Type{Bond{T}}) where T = T




function random_qubit(geometry::Geometry)
    i = rand(1:nQubits(geometry))
    return i
end

function qubits(geometry::Geometry)
    return 1:nQubits(geometry)
end
