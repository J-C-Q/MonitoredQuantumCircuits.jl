module MonitoredQuantumCircuits

# Write your package code here.
# using JLD2
# using IBMQClient
# using Configurations
# using IBMQClient.Schema
# using UUIDs


# include("Representations.jl")
# include("QobjAdapter.jl")
# include("IBMQAdapter.jl")

# export GeneralQuantumCircuit
# export PauliX
# export Hadamard
# export ControlledX
# export ProjectiveMeasurement
# export LinearRegister
# export IBMQuantumRegister
# export to_Qobj
# export IBMQrun
# export IBMQjobs
# export IBMQdevices

using Conda
using PyCall
using StatsBase
using Graphs
include("deps/build.jl")

include("QiskitAdapter.jl")

include("PreDefCircuits.jl")

include("ITensorsAdapter.jl")

export QiskitQuantumCircuit
export IBMQChip
export qiskitTranspile
export qiskitPrint
export ibmqRun

export randomCircuit
export nishimori

export itensorTest
end
