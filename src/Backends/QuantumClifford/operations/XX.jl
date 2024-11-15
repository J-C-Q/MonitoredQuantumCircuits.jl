function depth(::MonitoredQuantumCircuits.XX, ::Type{Circuit})
    return 1
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.XX, pos::Integer, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    qc.operations[pos] = QC.PauliMeasurement(QC.embed(qc.nQubits, (p1, p3), QC.P"XX"), clbit)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.XX, pos::Integer, step::Integer, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    apply!(qc, MonitoredQuantumCircuits.XX(), pos::Integer, Val(step), clbit, p1, p2, p3)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.XX, pos::Integer, ::Val{1}, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    qc.operations[pos] = QC.PauliMeasurement(QC.embed(qc.nQubits, (p1, p3), QC.P"XX"), clbit)
end

function apply!(::MonitoredQuantumCircuits.XX, clbit::Integer, qubits::Integer, p1::Integer, p2::Integer, p3::Integer)
    QC.PauliMeasurement(QC.embed(qubits, (p1, p3), QC.P"XX"), clbit)
end

function apply!(state::QC.Register, ::MonitoredQuantumCircuits.XX, qubits::Integer, clbit::Integer, p1::Integer, p2::Integer, p3::Integer)
    QC.apply!(state, QC.PauliMeasurement(QC.embed(qubits, (p1, p3), QC.P"XX"), clbit))
end
