# Geometry Interface

A **qubit geometry** represents the physical connectivity of qubits. Geometries are primarily intended to simplify the construction of circuits on various lattice structures, making it easier for users to implement and reason about their circuits. While geometries do not play a major role in the execution of circuits, they provide a convenient abstraction for circuit design.

Several [pre-implemented geometries](/library/geometries.md) are available. However, if you wish to define a custom geometry, this guide outlines the recommended approach.

## Defining a Geometry Type

To implement your own geometry, define a new `struct`:

```julia
struct MyGeometry <: Geometry
    graph::Graph
end
```

along with any necessary constructors.

## Recommended Methods

While not strictly required, the following methods are considered best practice and will help you construct and interact with circuits on your custom geometry.

### Indexing

It is often useful to support multiple indexing schemes, such as a one-dimensional linear index and a two-dimensional grid index. To facilitate conversions between these schemes, consider implementing:

```julia
function to_linear(geometry::MyGeometry, (i, j)::NTuple{2,Int64})
    # Convert a grid index to a linear index (integer)
end

function to_grid(geometry::MyGeometry, i::Int64)
    # Convert a linear index to a grid index (tuple)
end
```

### Neighbor Access

In many cases, it is important to identify the nearest neighbors of a qubit, for example, to apply two-qubit gates. Ideally, connections can be distinguished by their type, ensuring that each qubit has at most one neighbor of a given type. To support this, implement a neighbor-access method:

```julia
function neighbor(geometry::MyGeometry, i::Int64; direction::Symbol)
    # Return the neighbor of qubit `i` in the specified `direction`
    # Should return a linear index (integer)
end
```

### Visualization (Optional)

For improved usability in the REPL, you may wish to provide a visualization method:

```julia
function visualize(io::IO, geometry::MyGeometry)
    # Print a basic visualization of the geometry
end
```

## Example: All-to-All Connectivity

Below is an example implementation of a geometry with all-to-all connectivity:

```julia
using Graphs

struct CompleteGeometry <: Geometry
    graph::Graph
    size::Int64
    function CompleteGeometry(nQubits::Integer)
        graph = complete_graph(nQubits)
        new(graph, nQubits)
    end
end
```

By following these guidelines, you can create custom geometries that integrate seamlessly with the MonitoredQuantumCircuits.jl framework.