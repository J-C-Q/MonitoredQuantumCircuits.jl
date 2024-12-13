Currently, there are the following backends:

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