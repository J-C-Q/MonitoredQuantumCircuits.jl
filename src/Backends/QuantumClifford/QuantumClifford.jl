module QuantumClifford

import QuantumClifford as QC
using QuantumClifford
import ...MonitoredQuantumCircuits
using StatsBase
using LinearAlgebra

# include("circuit.jl")



include("Simulation.jl")
include("operations/X.jl")
include("operations/Y.jl")
include("operations/Z.jl")
include("operations/XX.jl")
include("operations/YY.jl")
include("operations/ZZ.jl")
include("operations/I.jl")
include("operations/H.jl")
include("operations/CNOT.jl")
include("operations/Pauli.jl")
include("operations/Measure_X.jl")
include("operations/Measure_Y.jl")
include("operations/Measure_Z.jl")

include("analysis.jl")


end
