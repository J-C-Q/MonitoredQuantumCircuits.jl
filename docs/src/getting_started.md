# Getting Started

The framework consists out of three main parts. First is the qubit geometry / lattice, which represents the underlying qubits structure. Second is the circuit, which holds information about the operations applied to the qubits in a given lattice. The last part is the execution of the circuit, which can happen on various backends.
As always, load MonitoredQuantumCircuits.jl (after [installing](/Home) it) using the `using` keyword for the following codesnipets to work
```julia
using MonitoredQuantumCircuits
```

## Qubit geometry / Lattice
A `Lattice` is a representation of qubits and connections between them (i.e., a graph). In general, it is only possible to apply operations to multiple qubits if they are connected in the lattice. Ancillary qubits should also be explicitly represented in the lattice. For more information see [Geometries](/Library/Geometries).
To construct a lattice object, call the constructor, e.g.,
```julia
lattice = HeavyChainLattice(10)
```
## Circuit
A circuit represents the operations being applied to the qubits in a lattice. As of now, there are two types of circuits

- `FiniteDepthCircuit`
- `RandomCircuit`

### FiniteDepthCircuit
This type of circuit stores an explicit representation of all operations in the circuit. Thus, making a deep circuit take up more memory. However, it makes it straightforward to iteratively construct circuits. Furthermore, it supports the graphical interface for circuit construction `GUI.CircuitComposer!(circuit<:FiniteDepthCircuit)`.

Usullay one would start with an empty circuit object for a given lattice
```julia
circuit = EmptyCircuit(lattice::Lattice)
```
which can then be iteratively constructed. Adding an operation is as easy as calling
```julia
apply!(circuit::Circuit, operation::Operation, position::Vararg{Integer})
```
where the number of arguments for `position` depends on the operation.


### RandomCircuit
This type of circuit stores operations and possible positions together with probabilities. This results in a trade of, where the execution of the circuit takes longer, however deep circuits do not run out of memory. Since the structure of the circuit is random, there are no iterative construction capabilities.


## Execution
To execute a quantum circuit, one first has to think about which backend to use. Currently, there are the following backends:

- Quantum computer
    - `IBMBackend(name::String)`
- Simulator
    - Qiskit Aer
        - `StateVectorSimulator()`
        - `GPUStateVectorSimulator()`
        - `CliffordSimulator()`
        - `GPUTensorNetworkSimulator()`
    - QuantumClifford
        - `TableauSimulator()`
        - `PauliFrameSimulator()`
        - `GPUPauliFrameSimulator()`

Now, one can execute the circuit using
```julia
execute!(circuit::Circuit, backend::Backend)
```

