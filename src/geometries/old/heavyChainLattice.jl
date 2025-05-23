"""
    HeavyChainLattice(length::Integer) <: Lattice

Create a heavy chain lattice with `length` system qubits and `length`-1 ancilla qubits inbeween.
"""
struct HeavyChainLattice <: Lattice
    graph::Graph
    isAncilla::Vector{Bool} # whether the qubit is an ancilla
    gridPositions::Vector{Tuple{Int64,Int64}} # the grid positions of the qubits
    function HeavyChainLattice(length::Integer)
        length > 0 || throw(ArgumentError("length must be positive"))
        graph = path_graph(2length - 1)
        isAncilla = Bool[i % 2 for i in 1:nv(graph)]
        gridPositions = [(i, 1) for i in 1:nv(graph)]
        return new(graph, isAncilla, gridPositions)
    end
end

# Re-define the outer constructor explicitly
# """
#     HeavyChainLattice(length::Integer)

# Create a heavy chain lattice with `length` system qubits and `length`-1 ancilla qubits inbeween.
# """
# HeavyChainLattice(length::Integer) = HeavyChainLattice(length)

function visualize(io::IO, chain::HeavyChainLattice)
    if nv(chain.graph) > 20
        return nothing
    end
    for i in 1:nv(chain.graph)-1
        print(io, "○─")
    end
    println(io, "○")
    return nothing
end
