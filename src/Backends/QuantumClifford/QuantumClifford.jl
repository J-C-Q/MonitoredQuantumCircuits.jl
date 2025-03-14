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
# include("operations/H.jl")
# include("operations/CNOT.jl")
include("operations/Pauli.jl")
# include("operations/Measure.jl")

include("analysis.jl")


end
