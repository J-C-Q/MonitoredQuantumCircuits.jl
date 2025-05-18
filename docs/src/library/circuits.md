# Circuits

A **circuit** represents a sequence of operations applied to the qubits in a given geometry. More precisely, a circuit is a temporally ordered list of operations. Operations may range from simple quantum gates and measurements to more complex procedures, such as randomly distributed gates; see the [operations](/library/operations.md) documentation for details.

Each circuit is defined on a specific geometry, which determines the arrangement and connectivity of qubits (typically represented as a graph). Operations can only be applied to qubits that are connected within the chosen geometry. For further information, refer to the [Geometries](/library/geometries.md) documentation.

Circuits are implemented as mutable structs, allowing for flexible construction and modification. This enables users to build circuits incrementally by adding operations as needed.

# Circuit Construction

To create an empty circuit, use the following constructor:

```julia
circuit = Circuit(geometry)
```

You may then iteratively apply operations:

```julia
apply!(circuit::Circuit, operation::Operation, position::Vararg{Integer})
```

Additional methods for `apply!` are available, enabling the application of more complex operations, such as random quantum gates with specified distributions. See the [operations](/library/operations.md) documentation for further details.

In the future, circuits may also be constructed using a graphical user interface. To launch the [Graphical User Interface](/modules/gui.md) (GUI, work in progress):

```julia
GUI.circuitComposer!(circuit)
```

## Compiling Circuits
To improve performance, circuits should be compiled. This process optimizes the circuit for execution. To compile a circuit, use the following command:

```julia
compile!(circuit::Circuit)
```

This command will return a compiled circuit, which can be executed on a selected backend.

## Predefined Circuits

MonitoredQuantumCircuits.jl provides several predefined circuits, which can be constructed using the appropriate functions. In accordance with Julia's multiple dispatch paradigm, these functions are only available for geometries supported by the respective circuit.

Currently, the following circuit construction functions are provided:

- **MonitoredTransverseFieldIsing**  

  Monitored quantum circuit version of the transverse field Ising model, supported on chain geometries.

- **MeasurementOnlyKitaev**  

  Measurement-only Kitaev model circuit, supported on honeycomb geometries.

- **MeasurementOnlyKekule**  

  Measurement-only Kekule model circuit, supported on honeycomb geometries.

- **MeasurementOnlyKekule_Floquet** 

  Measurement-only Kekule model circuit with Floquet time evolution, supported on honeycomb geometries.

- **MeasurementOnlyShastrySutherland**  

  Measurement-only Shastry-Sutherland model circuit, supported on Shastry-Sutherland geometries.


## Executing Circuits

To execute a compiled circuit, use the following command:

```julia
execute!(circuit::Circuit, backend::Backend)
```

This command will run the circuit on the specified backend and return the results in a format native to the backend.

---

## API Reference

```@docs
MonitoredTransverseFieldIsing
MeasurementOnlyKitaev
MeasurementOnlyKekule
MeasurementOnlyKekule_Floquet
MeasurementOnlyShastrySutherland
```