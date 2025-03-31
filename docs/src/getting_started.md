# Getting Started

The framework consists out of three main parts. First is the qubit geometry, which represents the underlying qubits structure. Second is the circuit, which holds information about the operations applied to the qubits in a given geometry. The last part is the execution of the circuit, which can happen on various backends.
As always, load MonitoredQuantumCircuits.jl (after [installing](/index.md) it) using the `using` keyword for the following code snippets to work
```julia
using MonitoredQuantumCircuits
```

## Choose a Geometry
A `Geometry` is a representation of qubits and connections between them (i.e., a graph). In general, it is only possible to apply operations to multiple qubits if they are connected in the geometry. For more information see [Geometries](/library/lattices.md).
To construct a geometry object, call a constructor, e.g.,
```julia
geometry = HoneycombGeometry(Periodic, 12, 12)
```

## Compose a Circuit
A circuit stores the [Operations](/library/operations.md) being applied to the qubits in a lattice. For more information see [Circuits](/library/circuits.md).
To construct a circuit object, call a constructor, e.g.,
```julia
circuit = MeasurementOnlyKitaev(geometry, px, py, pz; depth=100)
```
Or start an iterative construction by initializing an empty circuit
```julia
circuit = Circuit(geometry)
```
Now you could continue with the CLI and call `apply!` for different operations, or launch a [GUI](/modules/gui.md) (WIP) using 
```julia
GUI.CircuitComposer!(circuit)
```
Once you are done creating the circuit, compile it for faster iteration
```julia
compiled_circuit = compile(circuit)
```

## Execute
To execute a quantum circuit, you first have to think about which [Backend](/library/backends.md) to use.
For example a Clifford simulation using QuantumClifford.jl
```julia
simulator = QuantumClifford.TableauSimulator(nQubits(geometry))
```
or a state vector simulation using cuQuantum via Qiskit-Aer
```julia
simulator = Qiskit.GPUStateVectorSimulator()
```
Then, you can execute the circuit using
```julia
execute!(circuit::CompiledCircuit, backend::Backend)
```

