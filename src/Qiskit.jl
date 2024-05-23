struct QiskitQuantumCircuit
    qc::Py

    function QiskitQuantumCircuit(qc::PyCall.PyObject)
        return new(qc)
    end
    function QiskitQuantumCircuit(qubits::Int)
        return new(qiskit.QuantumCircuit(qubits))
    end
    function QiskitQuantumCircuit(qubits::Int, cbits::Int)
        return new(qiskit.QuantumCircuit(qubits, cbits))
    end
    function QiskitQuantumCircuit(qasm2code::String)
        return new(qasm2.loads(qasm2code))
    end
end
