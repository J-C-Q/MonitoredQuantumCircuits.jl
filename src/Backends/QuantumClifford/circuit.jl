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
    return qc
end
