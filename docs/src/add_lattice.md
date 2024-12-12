# How to add a new lattice?

A lattice or qubit geometry represents the physical connections  of the qubits.

## Create a lattice type
To implement your own lattice, create a struct
```julia
struct Mylattice <: Lattice
    graph::Graph
    isAncilla::Vector{Bool} # whether the qubit is an ancilla
    gridPositions::Vector{Tuple{Int64,Int64}} # the grid positions of the qubits for visualization
end
```
together with appropriate constructors. 

## CLI
Optionally, a visualize function can be written
```julia
function visualize(io::IO, lattice::Mylattice)
    # print a basic visualization of the lattice in the REPL
end
```
which results in a nicer CLI.

## Example
Here is an example of how one could implement an all-to-all connection geometry.

```julia
struct CompleteLattice <: Lattice
    graph::Graph
    isAncilla::Vector{Bool} # whether the qubit is an ancilla
    gridPositions::Vector{Tuple{Int64,Int64}} # the grid positions of the qubits for visualization
    function CompleteLattice(nQubits::Integer)
        graph = complete_graph(nQubits)
        isAncilla = falses(nQubits)
        gridPositions = [(cos(a), sin(a)) for a in range(0, 2pi, nQubits+1)[1:end-1]]
        new(graph, isAncilla, gridPositions)
    end
end

```

