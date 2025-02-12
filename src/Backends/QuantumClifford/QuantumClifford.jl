module QuantumClifford

import QuantumClifford as QC
using QuantumClifford
import ...MonitoredQuantumCircuits
using StatsBase

# include("circuit.jl")

include("Simulation.jl")

include("operations/XX.jl")
include("operations/YY.jl")
include("operations/ZZ.jl")
# include("operations/H.jl")
# include("operations/CNOT.jl")
include("operations/Pauli.jl")
# include("operations/Measure.jl")

include("analysis.jl")


end
