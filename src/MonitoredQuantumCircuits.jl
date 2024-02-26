module MonitoredQuantumCircuits

# Write your package code here.
using JLD2
using IBMQClient

# const account = AccountInfo("24519c61427d7a80665a014a79f7adbba12955cee6b72e48e3c09cb445e06aee1f43248cb2fd0ac4bada1e4d5ff6567eb61419eb95e569255ca37e57adcc6d73")

include("Representations.jl")
include("QobjAdapter.jl")
include("IBMQAdapter.jl")

export GeneralQuantumCircuit
export PauliX
export LinearRegister
export to_Qobj
export IBMQrun
export activateAccount

end
