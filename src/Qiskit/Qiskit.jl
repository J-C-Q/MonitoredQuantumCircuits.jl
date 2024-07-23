# """
#     Qiskit.jl

# A Julia module for interfacing with the needed [Qiskit](https://docs.quantum.ibm.com/api/qiskit) functionality using [PythonCall](https://juliapy.github.io/PythonCall.jl/stable/). (As well as [Qiskit_IBM_Runtime](https://docs.quantum.ibm.com/api/qiskit-ibm-runtime) and [Qiskit_Aer](https://qiskit.github.io/qiskit-aer/index.html))
# """
module Qiskit
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

#TODO apply indentitiy operation to all other qubits/maybe with transpile pass.
function qiskitRepresentation(circuit::Circuit)
    qc = Qiskit.QuantumCircuit(length(circuit.lattice))
    # iterate execution steps
    for i in unique(circuit.executionOrder)
        # get all operations in the step
        operationsInStep = _getOperations(circuit, i)
        # get depth of the deepest operation in the step
        maximumDepth = maximum([depth(circuit.operations[circuit.operationPointers[j]]) for j in operationsInStep])
        # iterate depth of the operations
        for k in 1:maximumDepth
            # iterate operations in the step
            for j in operationsInStep
                ptr = circuit.operationPointers[j]
                # only apply the k-th instruction of the operation, if deep enough
                if k <= depth(circuit.operations[ptr])
                    applyToQiskit!(qc, circuit.operations[ptr], k, circuit.operationPositions[j]...)
                end
            end
        end
    end
    return qc
end

end
