function depth(::MonitoredQuantumCircuits.ZZ, ::Type{Circuit})
    return 1
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.ZZ, p1::Integer, p2::Integer, p3::Integer)
    push!(qc, QC.PauliMeasurement(QC.embed(qc.nQubits, (p1, p3), QC.P"ZZ"), p2))
end
function apply!(qc::Circuit, ::MonitoredQuantumCircuits.ZZ, step::Integer, p1::Integer, p2::Integer, p3::Integer)
    apply!(qc, MonitoredQuantumCircuits.YY(), Val(step), p1, p2, p3)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.ZZ, ::Val{1}, p1::Integer, p2::Integer, p3::Integer)
    push!(qc, QC.PauliMeasurement(QC.embed(qc.nQubits, (p1, p3), QC.P"ZZ"), p2))
end
