# QuantumClifford.jl

```@meta
CurrentModule = MonitoredQuantumCircuits.QuantumClifford
```

[QuantumClifford.jl](https://github.com/QuantumSavory/QuantumClifford.jl) is a Julia package for simulating and manipulating quantum stabilizer states and Clifford circuits. It offers a comprehensive suite of tools for working with circuits that can be represented within the stabilizer formalism, providing both efficiency and ease of use for researchers and practitioners in quantum computing.

Within MonitoredQuantumCircuits.jl, QuantumClifford.jl serves as a backend for simulating quantum circuits that fall within the Clifford class. This enables efficient simulation of a wide range of quantum protocols and algorithms that can be described using stabilizer states.

## Available Backends

- **Simulators**
    - `TableauSimulator()`
    - `PauliFrameSimulator()`
    - `GPUPauliFrameSimulator()`

For details on how to understand the results, please refer to the [QuantumClifford.jl documentation](https://qc.quantumsavory.org/stable/).

---

## API Reference

```@docs; canonical=false
TableauSimulator
PauliFrameSimulator
GPUPauliFrameSimulator
```