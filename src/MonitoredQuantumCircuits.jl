module MonitoredQuantumCircuits

using Graphs
using JLD2
using Crayons
using Serialization
using StatsBase
using LinearAlgebra

using PythonCall
using CondaPkg



include("backend.jl")
# include("Remote/Remote.jl")
include("lattice.jl")
include("operations.jl")


include("lattices/PeriodicHoneycombLattice.jl")
include("lattices/ChainGeometry.jl")
include("lattices/TriangleSquareGeometry.jl")
include("lattices/SquareGeometry.jl")

include("operations/ZZ.jl")
include("operations/XX.jl")
include("operations/YY.jl")
include("operations/X.jl")
include("operations/Y.jl")
include("operations/Z.jl")
include("operations/Pauli.jl")
include("operations/H.jl")
include("operations/CNOT.jl")
include("operations/Measure_Z.jl")
include("operations/Measure_X.jl")
include("operations/Measure_Y.jl")
include("operations/Weak_ZZ.jl")
include("operations/Weak_YY.jl")
include("operations/Weak_XX.jl")
include("operations/RandomClifford.jl")
include("operations/Distributed.jl")
include("operations/I.jl")
include("operations/Random.jl")

include("circuit.jl")

# include("GUI/BonitoApp.jl")

include("Backends/Qiskit/Qiskit.jl")
# include("Backends/Stim/Stim.jl")
include("Backends/QuantumClifford/QuantumClifford.jl")
# include("Backends/cuQuantum/cuQuantum.jl")
# include("Backends/ITensorNetworks/ITensorNetworks.jl")

include("circuits/kitaev.jl")
include("circuits/kekule.jl")
include("circuits/MTFIM.jl")
include("circuits/kekule_floquet.jl")
include("circuits/triangle_square_XYZ.jl")
# include("circuits/random.jl")

export HoneycombGeometry
export ChainGeometry
export TriangleSquareGeometry
export Periodic
export plaquettes
export loops
export bonds
export subsystems
export subsystem
export nQubits
export random_qubit
export to_grid
export to_linear
export neighbor


export ZZ
export XX
export YY
export X
export Y
export Z
export NPauli
export RandomOperation
export DistributedOperation
export RandomClifford
export Measure_Z
export Measure_X
export Measure_Y
export H
export CNOT
export Measure
export Weak_ZZ
export Weak_XX
export Weak_YY



export Circuit
export apply!
export execute
export executeMPI
export depth
export nAncilla
export compile

export MeasurementOnlyKitaev
export MeasurementOnlyKekule
export MeasurementOnlyKekule_Floquet
export MonitoredTransverseFieldIsing
export MeasurementOnlyTriangleSquareXYZ


# export GUI

# export Remote

export Qiskit
# export Stim
export QuantumClifford
# export cuQuantum
# export ITensorNetworks

# export Analysis

end
