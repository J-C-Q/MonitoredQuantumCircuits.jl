
# The structure
- Operation
    - I
    - H
    - S
    - T
    - X
    - Y
    - Z
    - CNOT
    - MeasurementOperation
        - Measure
        - XX
        - YY
        - ZZ
        - Weak_XX
        - Weak_YY
        - Weak_ZZ
- Lattice
    - HeavyChainLattice
    - HeavySquareLattice
    - HeavyHexagonLattice
    - HexagonToricCodeLattice
- Circuit
- Backend
    - Simulator
        - Qiskit
            - StateVectorSimulator
            - GPUStateVectorSimulator
            - CliffordSimulator
            - GPUTensorNetworkSimulator
        - QuantumClifford
            - TableauSimulator
            - PauliFrameSimulator
            - GPUPauliFrameSimulator
        - Stim
            - CompileSimulator (PauliFrame)
        - ITensorNetworks (TBA)

    - QuantumComputer
        - Qiskit
            - IBMQ
- Remote


