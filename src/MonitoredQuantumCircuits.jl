module MonitoredQuantumCircuits

# TODO: Define a circuit geometry (e.g. IBMQChip)
# ? just use Graphs.jl
# TODO: Create methods to add gates to the circuit (representation in Qiskit) only allow next neighbors
# TODO: Create pre defined circuits (e.g. Nishimori)
# TODO: Create methode to run the circuit on IBMQ or simulate it with itensors on any computer


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
using FileIO
using Conda
using PyCall
using StatsBase
using Graphs
using GLMakie
using LinearAlgebra
using GLMakie.GeometryBasics
include("deps/build.jl")

include("QiskitAdapter.jl")

include("PreDefCircuits.jl")

include("ITensorsAdapter.jl")

include("GLMakiePrint.jl")

export QiskitQuantumCircuit
export IBMQChip
export qiskitTranspile
export qiskitPrint
export ibmqRun

export randomCircuit
export nishimori_on_Eagler3_1D

export itensorTest

export GLMakiePrint
end
