# """
#     Qiskit.jl

# A Julia module for interfacing with the needed [Qiskit](https://docs.quantum.ibm.com/api/qiskit) functionality using [PythonCall](https://juliapy.github.io/PythonCall.jl/stable/). (As well as [Qiskit_IBM_Runtime](https://docs.quantum.ibm.com/api/qiskit-ibm-runtime) and [Qiskit_Aer](https://qiskit.github.io/qiskit-aer/index.html))
# """
module Qiskit

import ..XX
import ..YY
import ..ZZ
import ..Circuit
import ..Operation
import ..Backend
import ..execute
import .._getOperations
import ..depth


using PythonCall


# import qiskit at run time
const qiskit = PythonCall.pynew()
const qiskit_ibm_runtime = PythonCall.pynew()
const qiskit_aer = PythonCall.pynew()
function __init__()
    PythonCall.pycopy!(qiskit, pyimport("qiskit"))
    PythonCall.pycopy!(qiskit_ibm_runtime, pyimport("qiskit_ibm_runtime"))
    PythonCall.pycopy!(qiskit_aer, pyimport("qiskit_aer"))
end

include("QuantumCircuit.jl")
include("IBMBackend.jl")
include("QiskitRuntimeService.jl")
include("Simulation.jl")
include("Sampler.jl")
include("Transpiler.jl")
include("Operations.jl")
include("operations/ZZ.jl")
include("operations/XX.jl")
include("operations/YY.jl")



end
