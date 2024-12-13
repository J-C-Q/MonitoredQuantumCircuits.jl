## Qubit Geometry / Lattice
A `Lattice` is a representation of qubits and connections between them (i.e., a graph). In general, it is only possible to apply operations to multiple qubits if they are connected in the lattice. Ancillary qubits should also be explicitly represented in the lattice. Preimplemented lattices are
```@docs
HeavyChainLattice(length::Integer)
```

- `HeavyChainLattice(length)`
- `HeavySquareLattice(sizeX, sizeY)`
- `HeavyHexagonLattice(sizeX, sizeY)`
- `HexagonToricCodeLattice(sizeX, sizeY)`