module IBM_interface

# Add the python dependicies at init
using PythonCall
const QISKIT = PythonCall.pynew()
const QISKIT_AER = PythonCall.pynew()
const QISKIT_IBM_PROVIDER = PythonCall.pynew()
const QISKIT_IBM_RUNTIME = PythonCall.pynew()
function __Init__()
    PythonCall.pycopy!(QISKIT, pyimport("qiskit"))
    PythonCall.pycopy!(QISKIT_AER, pyimport("qiski-aer"))
    PythonCall.pycopy!(QISKIT_IBM_PROVIDER, pyimport("qiskit-ibm-provider"))
    PythonCall.pycopy!(QISKIT_IBM_RUNTIME, pyimport("qiskit-ibm-runtime"))
end

function run_ibmq(circuit, backend)
    # run the circuit on the IBM quantum computer
    ibm_quantum_service = QISKIT_IBM_RUNTIME.QiskitRuntimeService()
end

function login(token)
    # Save an IBM Quantum account.
    QISKIT_IBM_RUNTIME#.QiskitRuntimeService.save_account(channel="ibm_quantum", token=token)
    QISKIT
end


end
