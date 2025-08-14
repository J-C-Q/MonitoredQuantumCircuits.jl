# Operations

```@meta
CurrentModule = MonitoredQuantumCircuits
```

Operations are the fundamental building blocks of quantum circuits. They represent the various quantum gates and measurements that can be applied to qubits. In MonitoredQuantumCircuits.jl, operations are defined as structs, allowing for flexible extension and customization. This section provides an overview of the available operations, and how to apply them to circuits. If you are interested in implementing your own operations, please refer to the [Operations Interface](/interfaces/add_operation.md) documentation.

## Available Operations

MonitoredQuantumCircuits.jl provides a variety of operations that can be applied to qubits within a circuit. These operations include unitary transformations and measurements. The following is a list of the available operations:
### Unitary Operations
::: info `I`

Represents the identity operation, which leaves the qubit unchanged.

:::
  
::: info `X`

Represents the Pauli-X operation, which flips the state of the qubit.

:::

::: info `Y`

Represents the Pauli-Y operation, which applies a bit-flip and phase-flip to the qubit.

:::

::: info `Z`

Represents the Pauli-Z operation, which applies a phase-flip to the qubit.

:::

::: info `H`

Represents the Hadamard operation, which creates superposition by transforming the basis states.

:::

::: info `CNOT`

Represents the controlled-NOT operation, which flips the target qubit if the control qubit is in the |1⟩ state.

:::

### Measurement Operations
::: info `MX`

Represents a measurement in the X basis, collapsing the qubit state to |+⟩ or |-⟩.

:::

::: info `MY`

Represents a measurement in the Y basis, collapsing the qubit state to |+i⟩ or |-i⟩.

:::

::: info `MZ`

Represents a measurement in the Z basis, collapsing the qubit state to |0⟩ or |1⟩.

:::

::: info `MXX`

Represents a parity measurement in the X basis.

:::

::: info `MYY`

Represents a parity measurement in the Y basis.

:::

::: info `MZZ`

Represents a parity measurement in the Z basis.

:::

::: info `WeakMXX`

Represents a weak parity measurement in the X basis.

:::

::: info `WeakMYY`

Represents a weak parity measurement in the Y basis.

:::

::: info `WeakMZZ`

Represents a weak parity measurement in the Z basis.

:::

::: info `MnPauli`

Represents a parity measurement, which can be applied to multiple qubits.

:::


---

## API Reference

```@docs; canonical=false
I
X
Y
Z
H
CNOT
MX
MY
MZ
MXX
MYY
MZZ
WeakMXX
WeakMYY
WeakMZZ
MnPauli
```