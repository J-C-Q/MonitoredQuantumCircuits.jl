## Qubit Geometry / Lattice

```@meta
CurrentModule = MonitoredQuantumCircuits
```

A `Lattice` is a representation of qubits and connections between them (i.e., a graph). In general, it is only possible to apply operations to multiple qubits if they are connected in the lattice. Ancillary qubits should also be explicitly represented in the lattice. Pre-implemented lattices are

```@docs
HeavyChainLattice
```

- `HeavyChainLattice(length)`
- `HeavySquareLattice(sizeX, sizeY)`
- `HeavyHexagonLattice(sizeX, sizeY)`
- `HexagonToricCodeLattice(sizeX, sizeY)`