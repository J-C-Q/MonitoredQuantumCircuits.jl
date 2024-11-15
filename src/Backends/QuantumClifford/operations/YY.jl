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

function apply!(::MonitoredQuantumCircuits.YY, clbit::Integer, qubits::Integer, p1::Integer, p2::Integer, p3::Integer)
    QC.PauliMeasurement(QC.embed(qubits, (p1, p3), QC.P"YY"), clbit)
end

function apply!(state::QC.Register, ::MonitoredQuantumCircuits.YY, qubits::Integer, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    QC.apply!(state, QC.PauliMeasurement(QC.embed(qubits, (p1, p3), QC.P"YY"), clbit))
end
