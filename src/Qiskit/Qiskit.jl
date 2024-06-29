module Qiskit
using PythonCall


# import qiskit at run time
const qiskit = PythonCall.pynew()
const qiskit_ibm_runtime = PythonCall.pynew()
function __init__()
    PythonCall.pycopy!(qiskit, pyimport("qiskit"))
    PythonCall.pycopy!(qiskit_ibm_runtime, pyimport("qiskit_ibm_runtime"))
end

include("QuantumCircuit.jl")
include("IBMBackend.jl")
include("QiskitRuntimeService.jl")
include("Sampler.jl")
include("Transpiler.jl")
end
