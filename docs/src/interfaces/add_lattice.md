# Geometry Interface

A qubit geometry represents the physical connections  of the qubits.

## Create a Geometry type
To implement your own geometry, create a struct
```julia
struct MyGeometry <: Geometry
    graph::Graph
end
```
together with appropriate constructors. 

## CLI
Optionally, a visualize function can be written
```julia
function visualize(io::IO, geometry::MyGeometry)
    # print a basic visualization of the geometry in the REPL
end
```
which results in a nicer CLI.

## Example
Here is an example of how one could implement an all-to-all connection geometry.

```julia
struct CompleteGeometry<: Geometry
    graph::Graph
    size::Int64
    function CompleteGeometry(nQubits::Integer)
        graph = complete_graph(nQubits)
        
        new(graph, nQubits)
    end
end

```

