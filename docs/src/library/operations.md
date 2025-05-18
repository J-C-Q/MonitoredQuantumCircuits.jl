# Operations

```@meta
CurrentModule = MonitoredQuantumCircuits
```

Operations are the fundamental building blocks of quantum circuits. They represent the various quantum gates and measurements that can be applied to qubits. In MonitoredQuantumCircuits.jl, operations are defined as structs, allowing for flexible extension and customization. This section provides an overview of the available operations, and how to apply them to circuits. If you are interested in implementing your own operations, please refer to the [Operations Interface](/interfaces/add_operation.md) documentation.

## Available Operations

MonitoredQuantumCircuits.jl provides a variety of operations that can be applied to qubits within a circuit. These operations include unitary transformations, measurements, and other quantum operations. The following is a list of the available operations:
### Unitary Operations
- **I**  

Represents the identity operation, which leaves the qubit unchanged.
  
- **X**

Represents the Pauli-X operation, which flips the state of the qubit.

- **Y**

Represents the Pauli-Y operation, which applies a bit-flip and phase-flip to the qubit.

- **Z**

Represents the Pauli-Z operation, which applies a phase-flip to the qubit.

- **H**

Represents the Hadamard operation, which creates superposition by transforming the basis states.

- **CNOT**

Represents the controlled-NOT operation, which flips the target qubit if the control qubit is in the |1⟩ state.

### Measurement Operations
- **MeasureX**

Represents a measurement in the X basis, collapsing the qubit state to |+⟩ or |-⟩.

- **MeasureY**

Represents a measurement in the Y basis, collapsing the qubit state to |+i⟩ or |-i⟩.

- **MeasureZ**

Represents a measurement in the Z basis, collapsing the qubit state to |0⟩ or |1⟩.

- **XX**

Represents a parity measurement in the X basis.

- **YY**

Represents a parity measurement in the Y basis.

- **ZZ**
Represents a parity measurement in the Z basis.

- **Weak_XX**

Represents a weak parity measurement in the X basis.

- **Weak_YY**

Represents a weak parity measurement in the Y basis.

- **Weak_ZZ**

Represents a weak parity measurement in the Z basis.

- **NPauli**

Represents a parity measurement, which can be applied to multiple qubits.

### Other Operations

- **RandomOperation**

Represents an operation constructed from mulitple unitary operations, each applied with a specified probability. The qubits on which the operation is applied can also be randomized.

- **DistributedOperation**

Represents an operation that is distributed across multiple qubits with specified probabilities.

---

## API Reference

```@docs; canonical=false
I
X
Y
Z
H
CNOT
MeasureX
MeasureY
MeasureZ
XX
YY
ZZ
Weak_XX
Weak_YY
Weak_ZZ
NPauli
RandomOperation
DistributedOperation
```