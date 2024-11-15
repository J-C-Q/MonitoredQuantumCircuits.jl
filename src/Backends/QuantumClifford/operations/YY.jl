function depth(::MonitoredQuantumCircuits.YY, ::Type{Circuit})
    return 1
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.YY, pos::Integer, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    qc.operations[pos] = QC.PauliMeasurement(QC.embed(qc.nQubits, (p1, p3), QC.P"YY"), clbit)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.YY, pos::Integer, step::Integer, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    apply!(qc, MonitoredQuantumCircuits.YY(), pos::Integer, Val(step), clbit, p1, p2, p3)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.YY, pos::Integer, ::Val{1}, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    qc.operations[pos] = QC.PauliMeasurement(QC.embed(qc.nQubits, (p1, p3), QC.P"YY"), clbit)
end
