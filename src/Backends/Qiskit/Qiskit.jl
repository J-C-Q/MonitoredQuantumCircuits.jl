# """
#     Qiskit.jl

# A Julia module for interfacing with the needed [Qiskit](https://docs.quantum.ibm.com/api/qiskit) functionality using [PythonCall](https://juliapy.github.io/PythonCall.jl/stable/). (As well as [Qiskit_IBM_Runtime](https://docs.quantum.ibm.com/api/qiskit-ibm-runtime) and [Qiskit_Aer](https://qiskit.github.io/qiskit-aer/index.html))
# """
module Qiskit

import ...MonitoredQuantumCircuits as MQC
import MonitoredQuantumCircuits.PythonCall as PythonCall
import MonitoredQuantumCircuits.CondaPkg as CondaPkg

function replaceOutput(f::Function, new_output::String)
    isinteractive() && print(new_output)
    original_stdout = stdout
    redirect_stdout(devnull) do
        f()
    end
    redirect_stdout(original_stdout)
    isinteractive() && println("✓")
end

# import qiskit at run time
const qiskit = PythonCall.pynew()
const qiskit_ibm_runtime = PythonCall.pynew()
const qiskit_aer = PythonCall.pynew()

function importQiskit()
    replaceOutput(
        () -> PythonCall.pycopy!(qiskit, PythonCall.pyimport("qiskit")),
        "Importing qiskit...")
    replaceOutput(
        () -> PythonCall.pycopy!(qiskit_ibm_runtime, PythonCall.pyimport("qiskit_ibm_runtime")),
        "Importing qiskit_ibm_runtime...")
end

function importQiskitAer(; gpu::Bool=false)
    if gpu
        if Sys.islinux()
            try
                replaceOutput(
                    () -> CondaPkg.add_pip("qiskit-aer-gpu"),
                    "Downloading qiskit_aer_gpu...\n")

                isinteractive() && println("qiskit-aer-gpu installed successfully.")
            catch
                isinteractive() && println("Failed to install qiskit-aer-gpu, using qiskit-aer instead.")
            end
        else
            isinteractive() && println("Non-Linux OS detected, gpu support disabled for qiskit-aer.")
        end
    end

    replaceOutput(
        () -> PythonCall.pycopy!(qiskit_aer, PythonCall.pyimport("qiskit_aer")),
        "Importing qiskit-aer...")
end

function _checkinit_qiskit()
    if PythonCall.pyisnull(qiskit)
        println("Qiskit not imported, importing now...")
        importQiskit()
    end
end

function _checkinit_qiskit_aer(; gpu::Bool=false)
    if PythonCall.pyisnull(qiskit_aer)
        println("Qiskit Aer not imported, importing now...")
        importQiskitAer()
    elseif gpu && !("GPU" in string.([device for device in qiskit_aer.AerSimulator().available_devices()]))
        println("Qiskit Aer imported without GPU support. Trying to import qiskit-aer-gpu...")
        importQiskitAer()
    end
end


include("QuantumCircuit.jl")
include("IBMBackend.jl")
include("QiskitRuntimeService.jl")
include("Result.jl")
include("Simulation.jl")
include("Sampler.jl")
include("Transpiler.jl")
include("Operations.jl")

include("operations/ZZ.jl")
include("operations/XX.jl")
include("operations/YY.jl")
include("operations/H.jl")
include("operations/CNOT.jl")
include("operations/Measure_Z.jl")
include("operations/Measure_X.jl")
include("operations/Measure_Y.jl")
include("operations/Weak_ZZ.jl")
include("operations/Weak_XX.jl")
include("operations/Weak_YY.jl")
include("operations/Pauli.jl")
include("operations/I.jl")
include("operations/X.jl")
include("operations/Y.jl")
include("operations/Z.jl")
end
