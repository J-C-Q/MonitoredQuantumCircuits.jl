# Getting Started

The framework consists out of three main parts. First is the qubit geometry / lattice, which represents the underlying qubits structure. Second is the circuit, which holds information about the operations applied to the qubits in a given lattice. The last part is the execution of the circuit, which can happen on various backends.
As always, load MonitoredQuantumCircuits.jl (after [installing](/index.md) it) using the `using` keyword for the following code snippets to work
```julia
using MonitoredQuantumCircuits
```

## Choose a Geometry
A `Lattice` is a representation of qubits and connections between them (i.e., a graph). In general, it is only possible to apply operations to multiple qubits if they are connected in the lattice. Ancillary qubits should also be explicitly represented in the lattice. For more information see [Geometries](/library/lattices.md).
To construct a lattice object, call a constructor, e.g.,
```julia
lattice = HeavyChainLattice(10)
```

## Compose a Circuit
A circuit stores the [Operations](/library/operations.md) being applied to the qubits in a lattice. For more information see [Circuits](/library/circuits.md).
To construct a lattice object, call a constructor, e.g.,
```julia
circuit = KitaevCircuit(lattice)
```
Or start an iterative construction by initializing an empty circuit
```julia
circuit = EmptyFiniteDepthCircuit(lattice)
```
Now you could continue with the CLI and call `apply!` for different operations (or use convenience functions like `H!(circuit)`), or launch a [GUI](/modules/gui.md) using 
 ```julia
GUI.CircuitComposer!(circuit)
```

## Execute
To execute a quantum circuit, you first have to think about which [Backend](/library/backends.md) to use.
Then, you can execute the circuit using
```julia
execute!(circuit::Circuit, backend::Backend)
```

