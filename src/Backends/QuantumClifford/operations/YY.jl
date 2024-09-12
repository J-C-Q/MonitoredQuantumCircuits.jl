function depth(::MonitoredQuantumCircuits.YY, ::Type{Circuit})
    return 1
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.YY, p1::Integer, p2::Integer, p3::Integer)
    push!(qc, QC.PauliMeasurement(QC.PauliOperator(0x00, nHot([p1, p3], qc.nQubits), nHot([p1, p3], qc.nQubits)), p2))
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.YY, step::Integer, p1::Integer, p2::Integer, p3::Integer)
    apply!(qc, MonitoredQuantumCircuits.YY(), Val(step), p1, p2, p3)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.YY, ::Val{1}, p1::Integer, p2::Integer, p3::Integer)
    push!(qc, QC.PauliMeasurement(QC.PauliOperator(0x00, nHot([p1, p3], qc.nQubits), nHot([p1, p3], qc.nQubits)), p2))
end
