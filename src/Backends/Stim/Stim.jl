module Stim

import ...MonitoredQuantumCircuits
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

# import stim at run time
const stim = PythonCall.pynew()

function importStim()
    replaceOutput(
        () -> PythonCall.pycopy!(stim, PythonCall.pyimport("stim")),
        "Importing stim...")
end

function _checkinit_stim()
    if PythonCall.pyisnull(stim)
        println("Stim not imported, importing now...")
        importStim()
    end
end

# function __init__()
#     replaceOutput(
#         () -> PythonCall.pycopy!(stim, pyimport("stim")),
#         "Importing stim...")
# end
include("StimCircuit.jl")
include("CompileSampler.jl")
include("TableauSampler.jl")
include("Simulation.jl")
include("operations/ZZ.jl")
include("operations/XX.jl")
include("operations/YY.jl")
include("operations/H.jl")
include("operations/CNOT.jl")




end
