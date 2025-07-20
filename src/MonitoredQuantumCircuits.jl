module MonitoredQuantumCircuits

using Graphs
# using JLD2
# using Serialization
# using StatsBase
# using LinearAlgebra

using PythonCall
using CondaPkg



include("backend.jl")
# include("Remote/Remote.jl")
include("geometry.jl")
include("operations.jl")


include("geometries/HoneycombLattice_Periodic.jl")
include("geometries/ChainGeometry.jl")
include("geometries/ShastrySutherlandGeometry.jl")
include("geometries/SquareGeometry.jl")
include("geometries/SquareOctagonGeometry.jl")
include("geometries/IBMQ_Falcon.jl")


include("operations/MZZ.jl")
include("operations/MXX.jl")
include("operations/MYY.jl")
include("operations/X.jl")
include("operations/Y.jl")
include("operations/Z.jl")
include("operations/Pauli.jl")
include("operations/H.jl")
include("operations/CNOT.jl")
include("operations/MZ.jl")
include("operations/MX.jl")
include("operations/MY.jl")
include("operations/WeakMZZ.jl")
include("operations/WeakMYY.jl")
include("operations/WeakMXX.jl")
include("operations/RandomClifford.jl")
include("operations/I.jl")


include("circuit.jl")
include("result.jl")

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
include("circuits/shastry_sutherland.jl")
include("circuits/nishimoris_cat.jl")
include("circuits/squareOctagon.jl")
include("circuits/fibonacci_drive.jl")

export ChainGeometry
export ShastrySutherlandGeometry
export SquareOctagonGeometry
export Periodic
export Open
export nQubits
export Bond
export nBonds
export random_qubit
export qubits
export random_bond

export I
export WeakMZZ
export WeakMXX
export WeakMYY
export MZZ
export MXX
export MYY
export X
export Y
export Z
export MnPauli
export RandomClifford
export MZ
export MX
export MY
export H
export CNOT




# export Circuit
export apply!
export reset!
export execute!
# export executeParallel
export depth
# export nAncilla
# export compile

export Result

export measurementOnlyKitaev!
export measurementOnlyKekule!
# export measurementOnlyKekule_Floquet!
export monitoredTransverseFieldIsing!
# export measurementOnlyShastrySutherland!
export monitoredGHZ!
# export measurementOnlySquareOctagon!
export monitoredTransverseFieldIsingFibonacci!

# export GUI

# export Remote

export Qiskit
# export Stim
export QuantumClifford
# export cuQuantum
# export ITensorNetworks
export get_measurements

# export Analysis

end
