module Stim

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
import ..Remote


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

# import stim at run time
const stim = PythonCall.pynew()

function __init__()
    replaceOutput(
        () -> PythonCall.pycopy!(stim, pyimport("stim")),
        "Importing stim...")
end
include("StimCircuit.jl")
include("CompileSampler.jl")
include("Simulation.jl")
include("operations/ZZ.jl")
include("operations/XX.jl")
include("operations/YY.jl")

# include("QuantumCircuit.jl")
# include("IBMBackend.jl")
# include("QiskitRuntimeService.jl")
# include("Simulation.jl")
# include("Sampler.jl")
# include("Transpiler.jl")
# include("Operations.jl")
# include("operations/ZZ.jl")
# include("operations/XX.jl")
# include("operations/YY.jl")



end
