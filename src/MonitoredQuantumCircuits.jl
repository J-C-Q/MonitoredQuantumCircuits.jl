module MonitoredQuantumCircuits

using PythonCall


const qiskit = PythonCall.pynew()
const qiskit_ibm_runtime = PythonCall.pynew()
const qiskit_ibm_provider = PythonCall.pynew()
const qiskit_aer = PythonCall.pynew()


# To not interact with python during precompilation
function __init__()
    PythonCall.Convert.pyconvert_add_rule("qiskit.circuit.quantumregister:Qubit", Qubit, _qiskitqubit_to_Qubit)
    PythonCall.Convert.pyconvert_add_rule("builtins.list", Vector{Qubit}, _qiskitqubit_list_to_Qubit_vector)

    PythonCall.pycopy!(qiskit, pyimport("qiskit"))
    PythonCall.pycopy!(qiskit_ibm_runtime, pyimport("qiskit_ibm_runtime"))
    PythonCall.pycopy!(qiskit_ibm_provider, pyimport("qiskit_ibm_provider"))
    PythonCall.pycopy!(qiskit_aer, pyimport("qiskit_aer"))
end
include("Qiskit_Wrapper/Qubit.jl")
include("Qiskit_Wrapper/Qiskit.jl")

export QuantumCircuit
end
