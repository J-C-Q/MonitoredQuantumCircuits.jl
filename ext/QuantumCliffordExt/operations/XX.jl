function depth(::MonitoredQuantumCircuits.XX, ::Type{Circuit})
    return 1
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.XX, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    push!(qc, QC.PauliMeasurement(QC.embed(qc.nQubits, (p1, p3), QC.P"XX"), clbit))
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.XX, step::Integer, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    apply!(qc, MonitoredQuantumCircuits.XX(), Val(step), clbit, p1, p2, p3)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.XX, ::Val{1}, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    push!(qc, QC.PauliMeasurement(QC.embed(qc.nQubits, (p1, p3), QC.P"XX"), clbit))
end
