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

A circuit encapsulates the [operations](/library/operations.md) applied to the qubits within a given geometry. For more information, see [Circuits](/library/circuits.md).

To create a circuit, you may use a predefined constructor:

```julia
circuit = MeasurementOnlyKitaev(geometry, px, py, pz; depth=100)
```

Alternatively, you can build a circuit iteratively by initializing an empty circuit:

```julia
circuit = Circuit(geometry)
```

You may then use the command-line interface to apply operations, or launch the [Graphical User Interface](/modules/gui.md) (GUI, work in progress):

```julia
GUI.CircuitComposer!(circuit)
```

Once your circuit is complete, compile it for improved performance:

```julia
compiled_circuit = compile(circuit)
```

## 3. Execute the Circuit

To execute a quantum circuit, first select an appropriate [backend](/library/backends.md). For example, to use a Clifford simulator via QuantumClifford.jl:

```julia
simulator = QuantumClifford.TableauSimulator(nQubits(geometry))
```

Or, for state vector simulation using cuQuantum through Qiskit-Aer:

```julia
simulator = Qiskit.GPUStateVectorSimulator()
```

Execute the compiled circuit on the chosen backend:

```julia
execute!(compiled_circuit, simulator)
```

For additional details, consult the [Backends](/library/backends.md) documentation.