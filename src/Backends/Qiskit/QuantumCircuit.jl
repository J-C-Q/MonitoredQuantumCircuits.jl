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
    return circuit.n_qubits
end

function depth(operation::MQC.Operation, ::Type{Circuit})
    throw(ArgumentError("depth in Qiskit is not implemented for $(typeof(operation)). Please implement this method for your custom operation."))
end

function translate(::Type{Circuit}, circuit::MQC.Circuit)
    _checkinit_qiskit()
    qc = Circuit(MQC.nQubits(circuit), MQC.nQubits(circuit))
    for i in 1:MQC.depth(circuit)
        operation, position = circuit[i]
        if typeof(operation) <: MQC.MeasurementOperation
            apply!(qc, operation, cbit, circuit.positions[i]...)
            cbit += 1
        else
            apply!(qc, operation, circuit.positions[i]...)
        end
    end
    return qc
end
