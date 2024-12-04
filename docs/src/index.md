```@raw html
---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "MonitoredQuantumCircuits.jl"
  text:
  tagline: A Julia first package to construct and execute monitored quantum circuits.
  image:
    src: /logo-square.png
    alt: MonitoredQuantumCircuits
  actions:
    - theme: brand
      text: Getting Started
      link: /getting_started
    - theme: alt
      text: View on Github
      link: https://github.com/J-C-Q/MonitoredQuantumCircuits.jl
    - theme: alt
      text: API
      link: /api
---
```

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


