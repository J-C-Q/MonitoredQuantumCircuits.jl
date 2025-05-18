## Backends

```@meta
CurrentModule = MonitoredQuantumCircuits
```

A **backend** is a computational engine responsible for executing quantum circuits. Backends may represent either actual quantum hardware or classical simulators. The backend executes the compiled circuit and returns the results for further analysis.

MonitoredQuantumCircuits.jl provides a range of built-in backends, encompassing both quantum computers and simulators. If you wish to integrate a custom backend, please refer to the [backend interface](/interfaces/add_backend.md) documentation.

### Available Backends

- **Quantum Computer**
    - `IBMBackend`

- **Simulators**
    - **Qiskit Aer**
        - `StateVectorSimulator`
        - `GPUStateVectorSimulator`
        - `CliffordSimulator`
        - `GPUTensorNetworkSimulator`
    - **QuantumClifford**
        - `TableauSimulator`
        - `PauliFrameSimulator`
        - `GPUPauliFrameSimulator`

### Selecting a Backend

Backends are organized into modules according to their origin. For example, backends provided by [Qiskit](/library/qiskit.md) reside in the `Qiskit` module, while those from [QuantumClifford](/library/quantum_clifford.md) are found in the `QuantumClifford` module. To instantiate a backend, prefix the constructor with the appropriate module name. For example, to create a state vector simulator using Qiskit:

```julia
backend = Qiskit.StateVectorSimulator()
```

For further details on backend capabilities and usage, consult the respective module documentation.