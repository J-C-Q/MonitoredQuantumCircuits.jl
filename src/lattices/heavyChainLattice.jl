struct HeavyChainLattice <: Lattice
    graph::Graph
    physicalMap::Vector{Int64} # the mapping to the physical qubits indices on a device
    function HeavyChainLattice(length::Integer)
        length > 0 || throw(ArgumentError("length must be positive"))
        graph = path_graph(2length - 1)
        physicalMap = fill(-1, 2length - 1)
        return new(graph, physicalMap)
    end
end

function visualize(io::IO, chain::HeavyChainLattice)
    for i in 1:nv(chain.graph)-1
        print(io, "o - ")
    end
    println(io, "o")
    return nothing
end
