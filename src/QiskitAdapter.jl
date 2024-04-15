
"""
A wrapper for the qiskit QuantumCircuit python class.
"""
struct QiskitQuantumCircuit
    qc::PyCall.PyObject

    function QiskitQuantumCircuit(qc::PyCall.PyObject)
        return new(qc)
    end
    function QiskitQuantumCircuit(qubits::Int)
        qiskit = pyimport("qiskit")
        return new(qiskit.QuantumCircuit(qubits))
    end
    function QiskitQuantumCircuit(qubits::Int, cbits::Int)
        qiskit = pyimport("qiskit")
        return new(qiskit.QuantumCircuit(qubits, cbits))
    end
    function QiskitQuantumCircuit(qasm2code::String)
        qasm2 = pyimport("qiskit.qasm2")
        return new(qasm2.loads(qasm2code))
    end
end

"""
A wrapper for the qiskit Sampler(V2) python class.
"""
struct IBMQChip
    backend::PyCall.PyObject
    sampler::PyCall.PyObject

    function IBMQChip(chip::String, token::String)
        qiskit_ibm_runtime = pyimport("qiskit_ibm_runtime")
        service = qiskit_ibm_runtime.QiskitRuntimeService(channel="ibm_quantum", token=token)
        backend = service.backend("ibm_" * chip)
        return new(backend, qiskit_ibm_runtime.Sampler(backend, options=qiskit_ibm_runtime.Options(optimization_level=0)))
    end
end

"""
Run a qiskit quantum circuit on an IBMQ chip.
"""
function ibmqRun(circuit::QiskitQuantumCircuit, chip::IBMQChip; shots=1024)
    chip.sampler.run(circuit.qc, shots=shots)
end

"""
Transpile a qiskit quantum circuit to an IBMQ chip
"""
function qiskitTranspile(circuit::QiskitQuantumCircuit, chip::IBMQChip)
    preset_passmanagers = pyimport("qiskit.transpiler.preset_passmanagers")
    pass_manager = preset_passmanagers.generate_preset_pass_manager(optimization_level=0, backend=chip.backend)
    return pass_manager.run(circuit.qc)
end

"""
A wrapper for the qiskit draw circuit function to remove the PyObject at the beginning.
"""
function qiskitPrint(circuit::QiskitQuantumCircuit)
    println(string(circuit.qc.draw())[10:end])
end
