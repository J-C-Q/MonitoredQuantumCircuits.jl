module QuantumClifford

import QuantumClifford as QC
import ...MonitoredQuantumCircuits
using StatsBase

# include("circuit.jl")
include("operations/XX.jl")
include("operations/YY.jl")
include("operations/ZZ.jl")
# include("operations/H.jl")
# include("operations/CNOT.jl")
include("operations/Pauli.jl")
# include("operations/Measure.jl")
include("Simulation.jl")
include("analysis.jl")


end
