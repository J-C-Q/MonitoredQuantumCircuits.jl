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



function MonitoredQuantumCircuits.translate(::Type{Circuit}, circuit::MonitoredQuantumCircuits.FiniteDepthCircuit)
    qc = Circuit(Vector{QC.AbstractOperation}(undef, length(circuit.operationPointers)), MonitoredQuantumCircuits.nQubits(circuit.lattice))
    measurementCount = 0

    for (i, ptr) in enumerate(circuit.operationPointers)
        if typeof(circuit.operations[ptr]) <: MonitoredQuantumCircuits.MeasurementOperation
            measurementCount += 1
            apply!(qc, circuit.operations[ptr], i, measurementCount, circuit.operationPositions[i]...)
        else
            apply!(qc, circuit.operations[ptr], i, circuit.operationPositions[i]...)
        end
    end








    # # iterate execution steps
    # for i in unique(circuit.executionOrder)
    #     # get all operations in the step
    #     operationsInStep = MonitoredQuantumCircuits._getOperations(circuit, i)
    #     # get depth of the deepest operation in the step
    #     maximumDepth = maximum([depth(circuit.operations[circuit.operationPointers[j]], Circuit) for j in operationsInStep])
    #     # iterate depth of the operations
    #     for k in 1:maximumDepth
    #         # iterate operations in the step
    #         for j in operationsInStep
    #             ptr = circuit.operationPointers[j]
    #             # only apply the k-th instruction of the operation, if deep enough
    #             if k <= depth(circuit.operations[ptr], Circuit)
    #                 if typeof(circuit.operations[ptr]) <: MonitoredQuantumCircuits.MeasurementOperation
    #                     if k <= MonitoredQuantumCircuits.nMeasurements(circuit.operations[ptr])
    #                         measurementCount += 1
    #                     end
    #                     apply!(qc, circuit.operations[ptr], i, k, measurementCount, circuit.operationPositions[j]...)
    #                 else
    #                     apply!(qc, circuit.operations[ptr], i, k, circuit.operationPositions[j]...)
    #                 end
    #             end
    #         end
    #     end
    # end
    return qc
end
