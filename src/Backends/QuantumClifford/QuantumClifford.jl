module QuantumClifford

import QuantumClifford as QC
using QuantumClifford
import ...MonitoredQuantumCircuits
using StatsBase
using LinearAlgebra


include("operations/util/fastSingleQubit.jl")

include("Simulation.jl")
include("operations/X.jl")
include("operations/Y.jl")
include("operations/Z.jl")
include("operations/MXX.jl")
include("operations/MYY.jl")
include("operations/MZZ.jl")
include("operations/I.jl")
include("operations/H.jl")
include("operations/CNOT.jl")
include("operations/Pauli.jl")
include("operations/MX.jl")
include("operations/MY.jl")
include("operations/MZ.jl")

include("analysis.jl")
end
