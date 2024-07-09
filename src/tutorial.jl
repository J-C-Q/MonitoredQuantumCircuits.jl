# # [MonitoredQuantumCircuits.jl Tutorial](@id tutorial)

# `MonitoredQuantumCircuits.jl` is a Julia package that simplifies research on quantum
# circuits focused on measurements. It offers an easy-to-use command line interface to
# create, simulate, and run (on IBM Quantum) quantum circuits on various lattice
# geometries. The package is designed to be modular and extendable.

# ## Tutorial - copy-pasteable version

# ```julia
# using MonitoredQuantumCircuits
# ```

# ## Input: a `Lattice`

using MonitoredQuantumCircuits

# The `Lattice` type is an abstract type that represents a lattice geometry. The package
# provides three concrete subtypes: `HeavyChainLattice`, `HeavySquareLattice`, and
# `HeavyHexagonLattice`. Each subtype has a constructor that takes the dimensions of the
# lattice as input.

# ### Heavy Chain lattice
chainLattice = HeavyChainLattice(3)

# ### Heavy Square lattice
squareLattice = HeavySquareLattice(2, 2)

# ### Heavy Hexagon lattice
hexagonLattice = HeavyHexagonLattice(2, 3)


# ## Input: a `Circuit`

# The `Circuit` type is an abstract type that represents a quantum circuit. The package
# provides a concrete subtype `EmptyCircuit` that represents an empty circuit. The
# constructor of `EmptyCircuit` takes a `Lattice` as input.

# ### Empty circuit on a Heavy Chain lattice
chainCircuit = EmptyCircuit(chainLattice)

# ### Empty circuit on a Heavy Square lattice
squareCircuit = EmptyCircuit(squareLattice)

# ### Empty circuit on a Heavy Hexagon lattice
hexagonCircuit = EmptyCircuit(hexagonLattice)
