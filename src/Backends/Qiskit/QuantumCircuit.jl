mutable struct Circuit
    python_interface::PythonCall.Py

    function Circuit(nQubits::Integer)
        _checkinit_qiskit()
        new(qiskit.QuantumCircuit(nQubits, nQubits))
    end

    function Circuit(nQubits::Integer, nClbits::Integer)
        _checkinit_qiskit()
        new(qiskit.QuantumCircuit(nQubits, nClbits))
    end
end
function Base.getproperty(qc::Circuit, prop::Symbol)
    if prop == :python_interface
        return getfield(qc, prop)
    else
        getproperty(qc.python_interface, prop)
    end
end
Base.show(io::IO, ::MIME"text/plain", obj::Circuit) = print(io, obj.python_interface)


function nQubits(circuit::Circuit)
    return circuit.num_qubits
end


