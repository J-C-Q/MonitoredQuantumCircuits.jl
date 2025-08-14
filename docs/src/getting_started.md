# Getting Started

MonitoredQuantumCircuits.jl is structured around three core components: **qubit geometry**, **circuit construction**, and **circuit execution**. This guide provides a concise overview to help you begin using the framework effectively.

Before proceeding, ensure that MonitoredQuantumCircuits.jl is [installed](/index.md) and loaded:

```julia
using MonitoredQuantumCircuits
```

## 1. Select a Geometry

A `Geometry` defines the arrangement and connectivity of qubits, typically represented as a graph. Operations can only be applied to qubits that are connected within the chosen geometry. For further details, refer to the [Geometries](/library/geometries.md) documentation.

To construct a geometry object, use one of the provided constructors. For example:

```julia
geometry = HoneycombGeometry(Periodic, 12, 12)
```

## 2. Construct a Circuit

A circuit encapsulates the [operations](/library/operations.md) applied to the qubits within a given geometry. The exact representation of the circuit depends on the backend.

To create a circuit, you must first pick a [backend](/library/backends.md).
For example a Clifford circuit can be efficiently represented using a stabilizer tableau.

```julia
backend = QuantumClifford.TableauSimulator(nqubits::Int)
```

Now you can apply operations to the circuit using

```julia
apply!(backend::Backend, ::Operation, position)
```

It is best practice, to constructing the circuit in a separate function

```julia
function circuit!(::Backend)
    # apply! ...
end
```


## 3. Execute the Circuit

To execute the circuit run

```julia
execute!(() -> circuit!(backend), ::Backend, post_processing::Function)
```

where the `post_processing` function takes the shot index and could compute some property of the circuit.

For additional details, consult the [Backends](/library/backends.md) documentation.