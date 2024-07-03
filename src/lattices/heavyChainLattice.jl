struct HeavyChainLattice <: Lattice
    graph::Graph
    isAncilla::Vector{Bool} # whether the qubit is an ancilla
    physicalMap::Vector{Int64} # the mapping to the physical qubits indices on a device
    function HeavyChainLattice(length::Integer)
        length > 0 || throw(ArgumentError("length must be positive"))
        graph = path_graph(2length - 1)
        isAncilla = Bool[i % 2 for i in 1:nv(graph)]
        physicalMap = fill(-1, 2length - 1)
        return new(graph, isAncilla, physicalMap)
    end
end

function visualize(io::IO, chain::HeavyChainLattice)
    for i in 1:nv(chain.graph)-1
        print(io, "○─")
    end
    println(io, "○")
    return nothing
end
