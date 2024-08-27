abstract type Lattice end
function getBonds(lattice::Lattice)
    bonds = collect(edges(lattice.graph))
    return [(src(e), dst(e)) for e in bonds]
end

function Base.length(lattice::Lattice)
    return nv(lattice.graph)
end

function nQubits(lattice::Lattice; countAncilla::Bool=false)
    return countAncilla ? nv(lattice.graph) : sum(lattice.isAncilla .== false)
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
    # allequal([lattice.physicalMap[i] == -1 for i in 1:length(lattice)]) ? println(io, "No mapping to chip defined") : println(io, "physicalMap: ", lattice.physicalMap)
    nv(lattice.graph) <= 100 && visualize(io, lattice)
end


include("lattices/heavyChainLattice.jl")
include("lattices/heavySquareLattice.jl")
include("lattices/heavyHexagonLattice.jl")
include("lattices/surfaceCodeLattice.jl")
# include("lattices/toricCodeLattice.jl")
