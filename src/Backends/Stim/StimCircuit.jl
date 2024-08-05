mutable struct StimCircuit
    python_interface::Py
    StimCircuit() = new(stim.Circuit())
end
function Base.getproperty(qc::StimCircuit, prop::Symbol)
    if prop == :python_interface
        return getfield(qc, prop)
    else
        getproperty(qc.python_interface, prop)
    end
end
Base.show(io::IO, ::MIME"text/plain", obj::StimCircuit) = print(io, obj.python_interface)


function translate(::Type{StimCircuit}, circuit::Circuit)
    qc = StimCircuit()
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
                    apply!(qc, circuit.operations[ptr], k, circuit.operationPositions[j]...)
                end
            end
        end
    end
    qc.append("M", range(0, length(circuit.lattice) - 1))
    return qc
end
