# Qiskit

```@meta
CurrentModule = MonitoredQuantumCircuits.Qiskit
```

[Qiskit](https://www.ibm.com/quantum/qiskit) is a comprehensive quantum computing framework developed by IBM. It provides a robust suite of tools for constructing, simulating, and executing quantum circuits, supporting both real quantum hardware and high-performance classical simulators.

Within MonitoredQuantumCircuits.jl, Qiskit serves as a backend interface, enabling users to leverage Qiskit's advanced simulation capabilities and access IBM's quantum devices.

## Available Backends

- **Quantum Computer**
    - `IBMBackend`
- **Simulators**
    - `StateVectorSimulator`
    - `GPUStateVectorSimulator`
    - `CliffordSimulator`
    - `GPUTensorNetworkSimulator`

For detailed usage instructions and advanced features, please refer to the [Qiskit documentation](https://quantum.cloud.ibm.com/docs/en/api/qiskit).

---

## API Reference

```@docs; canonical=false
IBMBackend
StateVectorSimulator
GPUStateVectorSimulator
CliffordSimulator
GPUTensorNetworkSimulator
```