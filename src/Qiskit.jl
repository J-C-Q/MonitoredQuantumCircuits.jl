struct QuantumCircuit
    qc::Py

    function QuantumCircuit(qc::QuantumCircuit)
        return new(qc.qc)
    end
    function QuantumCircuit(qubits::Int; name::String="", global_phase::Float64=0.0)
        return new(qiskit.QuantumCircuit(qubits))
    end
    function QuantumCircuit(qubits::Int, cbits::Int)
        return new(qiskit.QuantumCircuit(qubits, cbits))
    end
    # function QiskitQuantumCircuit(qasm2code::String)
    #     return new(qasm2.loads(qasm2code))
    # end
end
Base.show(io::IO, ::MIME"text/plain", obj::QuantumCircuit) = print(io, obj.qc)
function Base.getproperty(qc::QuantumCircuit, prop::Symbol)
    if prop == :qc
        return getfield(qc, prop)
    else
        return getproperty(qc.qc, prop)
    end
end
