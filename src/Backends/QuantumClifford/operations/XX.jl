function depth(::MonitoredQuantumCircuits.XX, ::Type{Circuit})
    return 1
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.XX, p1::Integer, p2::Integer, p3::Integer)
    push!(qc, QC.PauliMeasurement(QC.PauliOperator(0x00, nHot([p1, p3], qc.nQubits), nHot([], qc.nQubits)), p2))
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.XX, step::Integer, p1::Integer, p2::Integer, p3::Integer)
    apply!(qc, MonitoredQuantumCircuits.XX(), Val(step), p1, p2, p3)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.XX, ::Val{1}, p1::Integer, p2::Integer, p3::Integer)
    push!(qc, QC.PauliMeasurement(QC.PauliOperator(0x00, nHot([p1, p3], qc.nQubits), nHot([], qc.nQubits)), p2))
end
