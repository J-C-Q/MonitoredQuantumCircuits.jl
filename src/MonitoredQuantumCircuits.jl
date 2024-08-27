module MonitoredQuantumCircuits

using Graphs
using JLD2
using Crayons

include("backend.jl")
include("Remote/Remote.jl")
include("lattice.jl")
include("operations.jl")
include("circuit.jl")
include("result.jl")
include("operations/ZZ.jl")
include("operations/XX.jl")
include("operations/YY.jl")
include("GUI/BonitoApp.jl")

include("Backends/Qiskit/Qiskit.jl")
include("Backends/Stim/Stim.jl")
# include("Backends/ITensorNetworks/ITensorNetworks.jl")
include("circuits/utils/cycles.jl")
include("circuits/nishimori.jl")
include("circuits/kitaev.jl")
include("circuits/kekule.jl")
include("circuits/random.jl")




export Circuit
export EmptyCircuit
export apply!
export isClifford
export execute
export translate


export ZZ
export XX
export YY

export HeavyChainLattice
export HeavySquareLattice
export HeavyHexagonLattice
export SurfaceCodeLattice
# export ToricCodeLattice

export NishimoriCircuit
export KitaevCircuit
export KekuleCircuit
export RandomCircuit

export GUI

export Remote

export Qiskit
export Stim
# export ITensorNetworks


end
