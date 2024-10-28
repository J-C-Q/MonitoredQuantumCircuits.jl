mutable struct QuantumCircuit
    python_interface::PythonCall.Py

    function QuantumCircuit(nQubits::Integer)
        _checkinit_qiskit()
        new(qiskit.QuantumCircuit(nQubits, nQubits))
    end

    function QuantumCircuit(nQubits::Integer, nClbits::Integer)
        _checkinit_qiskit()
        new(qiskit.QuantumCircuit(nQubits, nClbits))
    end
end
function Base.getproperty(qc::QuantumCircuit, prop::Symbol)
    if prop == :python_interface
        return getfield(qc, prop)
    else
        getproperty(qc.python_interface, prop)
    end
end
Base.show(io::IO, ::MIME"text/plain", obj::QuantumCircuit) = print(io, obj.python_interface)



function depth(operation::MonitoredQuantumCircuits.Operation, ::Type{QuantumCircuit})
    throw(ArgumentError("depth in Qiskit is not implemented for $(typeof(operation)). Please implement this method for your custom operation."))
end

#TODO apply indentitiy operation to all other qubits/maybe with transpile pass.
function MonitoredQuantumCircuits.translate(::Type{QuantumCircuit}, circuit::MonitoredQuantumCircuits.Circuit)
    _checkinit_qiskit()
    qc = QuantumCircuit(length(circuit.lattice), MonitoredQuantumCircuits.nMeasurements(circuit))
    measurementCount = 0
    # iterate execution steps
    for i in unique(circuit.executionOrder)
        # get all operations in the step
        operationsInStep = MonitoredQuantumCircuits._getOperations(circuit, i)
        # get depth of the deepest operation in the step
        maximumDepth = maximum([depth(circuit.operations[circuit.operationPointers[j]], QuantumCircuit) for j in operationsInStep])
        # iterate depth of the operations
        for k in 1:maximumDepth
            # iterate operations in the step
            for j in operationsInStep
                ptr = circuit.operationPointers[j]
                # only apply the k-th instruction of the operation, if deep enough
                if k <= depth(circuit.operations[ptr], QuantumCircuit)
                    if typeof(circuit.operations[ptr]) <: MonitoredQuantumCircuits.MeasurementOperation
                        if k <= MonitoredQuantumCircuits.nMeasurements(circuit.operations[ptr])
                            measurementCount += 1
                        end
                        apply!(qc, circuit.operations[ptr], k, measurementCount, circuit.operationPositions[j]...)
                    else
                        apply!(qc, circuit.operations[ptr], k, circuit.operationPositions[j]...)
                    end
                end
            end
        end
    end
    return qc
end
