mutable struct StimCircuit
    python_interface::PythonCall.Py
    function StimCircuit()
        _checkinit_stim()
        new(stim.Circuit())
    end
end
function Base.getproperty(qc::StimCircuit, prop::Symbol)
    if prop == :python_interface
        return getfield(qc, prop)
    else
        getproperty(qc.python_interface, prop)
    end
end
Base.show(io::IO, ::MIME"text/plain", obj::StimCircuit) = print(io, obj.python_interface)

function depth(operation::MonitoredQuantumCircuits.Operation, ::Type{StimCircuit})
    throw(ArgumentError("depth in Stim is not implemented for $(typeof(operation)). Please implement this method for your custom operation."))
end

function MonitoredQuantumCircuits.translate(::Type{StimCircuit}, circuit::MonitoredQuantumCircuits.Circuit)
    _checkinit_stim()
    qc = StimCircuit()

    # qc.append("DEPOLARIZE1", collect(0:MonitoredQuantumCircuits.nQubits(circuit.lattice)-1), 0.75)

    # iterate execution steps
    for i in unique(circuit.executionOrder)
        # get all operations in the step
        operationsInStep = MonitoredQuantumCircuits._getOperations(circuit, i)
        # get depth of the deepest operation in the step
        maximumDepth = maximum([depth(circuit.operations[circuit.operationPointers[j]], StimCircuit) for j in operationsInStep])
        # iterate depth of the operations
        for k in 1:maximumDepth
            # iterate operations in the step
            for j in operationsInStep
                ptr = circuit.operationPointers[j]
                # only apply the k-th instruction of the operation, if deep enough
                if k <= depth(circuit.operations[ptr], StimCircuit)
                    apply!(qc, circuit.operations[ptr], k, circuit.operationPositions[j]...)
                end
            end
        end
    end
    # qc.append("M", [i for i in 0:length(circuit.lattice)-1 if !circuit.lattice.isAncilla[i+1]])
    return qc
end
