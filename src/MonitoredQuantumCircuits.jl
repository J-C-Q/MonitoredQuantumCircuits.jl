module MonitoredQuantumCircuits

using Graphs
using JLD2
using Crayons
using Serialization

using PythonCall
using CondaPkg



include("backend.jl")
# include("Remote/Remote.jl")
include("lattice.jl")
include("operations.jl")
include("circuit_new.jl")
# # include("circuit.jl")
# include("result.jl")

include("lattices/PeriodicHoneycombLattice.jl")
# include("lattices/heavyChainLattice.jl")
# include("lattices/heavySquareLattice.jl")
# include("lattices/heavyHexagonLattice.jl")
# include("lattices/squareSurfaceCodeLattice.jl")
# include("lattices/squareToricCodeLattice.jl")
# include("lattices/hexagonToricCodeLattice.jl")

include("operations/ZZ.jl")
include("operations/XX.jl")
include("operations/YY.jl")
include("operations/X.jl")
include("operations/Y.jl")
include("operations/Z.jl")
include("operations/Pauli.jl")
include("operations/H.jl")
include("operations/CNOT.jl")
include("operations/Measure.jl")
include("operations/Weak_ZZ.jl")
include("operations/Weak_YY.jl")
include("operations/Weak_XX.jl")

# include("GUI/BonitoApp.jl")

include("Backends/Qiskit/Qiskit.jl")
# include("Backends/Stim/Stim.jl")
include("Backends/QuantumClifford/QuantumClifford.jl")
include("Backends/cuQuantum/cuQuantum.jl")
# # include("Backends/ITensorNetworks/ITensorNetworks.jl")
# include("circuits/utils/cycles.jl")
# include("circuits/nishimori.jl")
# include("circuits/kitaev.jl")
# include("circuits/kekule.jl")
# include("circuits/random.jl")

export HoneycombGeometry
export Periodic
export kitaevX
export kitaevY
export kitaevZ
export isKitaevX
export isKitaevY
export isKitaevZ
export isKitaev_
export kitaevX_neighbor
export kitaevY_neighbor
export kitaevZ_neighbor
export plaquettes
export long_cycles
export kitaevType
export nQubits
export random_qubit

# export FiniteDepthCircuit
# export RandomCircuit
# export EmptyFiniteDepthCircuit
# export apply!
# export isClifford
# export execute
# export translate


export ZZ
export XX
export YY
export X
export Y
export Z
export nPauli
# export H
# export CNOT
# export Measure
# export Weak_ZZ
# export Weak_XX
# export Weak_YY

# export Lattice
# export HeavyChainLattice
# export HeavySquareLattice
# export HeavyHexagonLattice
# export SquareSurfaceCodeLattice
# export SquareToricCodeLattice
# export HexagonToricCodeLattice

# export NishimoriCircuit
# export KitaevCircuit
# export KekuleCircuit
# export RandomCircuit
export Circuit
export apply!
export execute
export reset!
export hard_reset!
export depth
# export RandomCircuit

# export GUI

# export Remote

export Qiskit
# export Stim
export QuantumClifford
export cuQuantum
# # export ITensorNetworks

# export Analysis

end
