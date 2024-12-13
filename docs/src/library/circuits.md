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

