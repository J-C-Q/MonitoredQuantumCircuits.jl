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
import ..translate


using PythonCall
using CondaPkg

function replaceOutput(f::Function, new_output::String)
    print(new_output)
    original_stdout = stdout
    redirect_stdout(devnull) do
        f()
    end
    redirect_stdout(original_stdout)
    println("✓")
end

# import qiskit at run time
const qiskit = PythonCall.pynew()
const qiskit_ibm_runtime = PythonCall.pynew()
const qiskit_aer = PythonCall.pynew()
function __init__()
    replaceOutput(
        () -> PythonCall.pycopy!(qiskit, pyimport("qiskit")),
        "Importing qiskit...")

    replaceOutput(
        () -> PythonCall.pycopy!(qiskit_ibm_runtime, pyimport("qiskit_ibm_runtime")),
        "Importing qiskit_ibm_runtime...")

    # if Sys.islinux()
    #     try
    #         replaceOutput(
    #             () -> CondaPkg.add_pip("qiskit-aer-gpu"),
    #             "Downloading qiskit_aer_gpu...")

    #         println("qiskit-aer-gpu installed successfully.")
    #     catch
    #         println("Failed to install qiskit-aer-gpu, using qiskit-aer instead.")
    #     end
    # else
    #     println("Non-Linux OS detected, gpu support disabled for qiskit-aer.")
    # end

    replaceOutput(
        () -> PythonCall.pycopy!(qiskit_aer, pyimport("qiskit_aer")),
        "Importing qiskit-aer...")
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
