"""
A data structure representing a one-dimensional chain geometry of qubits.

## Constructors
```julia
ChainGeometry(Periodic, size::Integer)
```
Constructs a chain geometry with periodic boundary conditions (i.e., a closed loop).
```julia
ChainGeometry(Open, size::Integer)
```
Constructs a chain geometry with open boundary conditions (i.e., a linear chain).

## Arguments

- `size::Integer`: The number of qubits in the chain.

## Examples

```julia
# Create a chain of 8 qubits with periodic boundaries
geometry = ChainGeometry(Periodic, 8)

# Create a chain of 10 qubits with open boundaries
geometry = ChainGeometry(Open, 10)
```
"""
struct ChainGeometry{T<:BoundaryCondition} <: Geometry
    graph::Graphs.SimpleGraphs.SimpleGraph{Int64}
    size::Int64
    bonds::Vector{Bond{Int64}}
    function ChainGeometry(type::Type{Periodic}, size::Integer)
        graph = Graphs.cycle_graph(size)
        new{type}(graph, size, collectBonds(graph))
    end
    function ChainGeometry(type::Type{Open}, size::Integer)
        graph = Graphs.cycle_graph(size)
        Graphs.rem_edge!(graph, 1, size)  # Remove the edge to make it open
        new{type}(graph, size, collectBonds(graph))
    end
end

function collectBonds(graph::Graphs.SimpleGraphs.SimpleGraph{Int64})
    bonds = Vector{Bond{Int64}}(undef, ne(graph))
    for (i, e) in enumerate(Graphs.edges(graph))
        bonds[i] = Bond(Graphs.src(e), Graphs.dst(e))
    end
    return bonds
end

function bonds(geometry::ChainGeometry)
    return geometry.bonds
end
