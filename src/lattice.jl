
"""
    Geometry

Abstract type for the geometry of the qubits.
"""
abstract type Geometry end
abstract type BoundaryCondition end
abstract type Periodic <: BoundaryCondition end
abstract type Open <: BoundaryCondition end

function getBonds(lattice::Geometry)
    bonds = collect(edges(lattice.graph))
    return [(src(e), dst(e)) for e in bonds]
end

function Base.length(lattice::Geometry)
    return nv(lattice.graph)
end

"""
    nQubits(lattice::Geometry)

Return the number of qubits in the gemoetry.
"""
function nQubits(lattice::Geometry)
    return nv(lattice.graph)
end

function Base.show(io::IO, lattice::Geometry)
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
    nv(lattice.graph) <= 100 && visualize(io, lattice)
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
