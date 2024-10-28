module QuantumClifford

import QuantumClifford as QC
import ...MonitoredQuantumCircuits

include("circuit.jl")
include("operations/XX.jl")
include("operations/YY.jl")
include("operations/ZZ.jl")
include("operations/H.jl")
include("operations/CNOT.jl")
include("operations/Measure.jl")
include("Simulation.jl")
include("analysis.jl")


end
