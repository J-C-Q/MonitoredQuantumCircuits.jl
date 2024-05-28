module MonitoredQuantumCircuits

using PythonCall
PythonCall.printPyPrefix!(false)

const qiskit = PythonCall.pynew()
const qiskit_ibm_runtime = PythonCall.pynew()
const qiskit_ibm_provider = PythonCall.pynew()
const qiskit_aer = PythonCall.pynew()

# To not interact with python during precompilation
function __init__()
    PythonCall.pycopy!(qiskit, pyimport("qiskit"))
    PythonCall.pycopy!(qiskit_ibm_runtime, pyimport("qiskit_ibm_runtime"))
    PythonCall.pycopy!(qiskit_ibm_provider, pyimport("qiskit_ibm_provider"))
    PythonCall.pycopy!(qiskit_aer, pyimport("qiskit_aer"))
end

include("Qiskit_Wrapper/Qiskit.jl")

export QuantumCircuit
end
