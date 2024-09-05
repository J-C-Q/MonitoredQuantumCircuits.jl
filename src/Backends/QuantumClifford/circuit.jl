struct Circuit
    operations::Vector{QC.AbstractOperation}
    nQubits::Integer
end

function Base.show(io::IO, ::MIME"text/plain", qc::Circuit)
    print(io, qc.operations)
end

function Base.push!(qc::Circuit, operation::QC.AbstractOperation)
    push!(qc.operations, operation)
end



function MonitoredQuantumCircuits.translate(::Type{Circuit}, circuit::MonitoredQuantumCircuits.Circuit)
    qc = Circuit([], MonitoredQuantumCircuits.nQubits(circuit.lattice))

    # iterate execution steps
    for i in unique(circuit.executionOrder)
        # get all operations in the step
        operationsInStep = MonitoredQuantumCircuits._getOperations(circuit, i)
        # get depth of the deepest operation in the step
        maximumDepth = maximum([depth(circuit.operations[circuit.operationPointers[j]], Circuit) for j in operationsInStep])
        # iterate depth of the operations
        for k in 1:maximumDepth
            # iterate operations in the step
            for j in operationsInStep
                ptr = circuit.operationPointers[j]
                # only apply the k-th instruction of the operation, if deep enough
                if k <= depth(circuit.operations[ptr], Circuit)
                    apply!(qc, circuit.operations[ptr], k, circuit.operationPositions[j]...)
                end
            end
        end
    end
    return qc
end
