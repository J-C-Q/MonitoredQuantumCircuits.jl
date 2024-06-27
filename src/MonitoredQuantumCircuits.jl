module MonitoredQuantumCircuits

using PythonCall
using Graphs

# import qiskit at run time
const qiskit = PythonCall.pynew()
function __init__()
    PythonCall.pycopy!(qiskit, pyimport("qiskit"))
end

include("operations.jl")
include("lattice.jl")
include("circuit.jl")

export Circuit
export EmptyCircuit
export NishimoriCircuit
export apply!

export Operation
export ZZ
export XX
export YY

export Lattice
export HeavyChainLattice
export HeavySquareLattice
export HeavyHexagonLattice


end
