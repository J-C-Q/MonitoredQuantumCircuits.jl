function depth(::MonitoredQuantumCircuits.Measure, ::Type{Circuit})
    return 1
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.Measure, pos::Integer, clbit::Integer, p::Integer)
    qc.operations[pos] = QC.sMZ(p, clbit)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.Measure, pos::Integer, step::Integer, clbit::Integer, p::Integer)
    apply!(qc, MonitoredQuantumCircuits.Measure(), pos::Integer, Val(step), clbit, p)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.Measure, pos::Integer, ::Val{1}, clbit::Integer, p::Integer)
    qc.operations[pos] = QC.sMZ(p, clbit)
end

function apply!(::MonitoredQuantumCircuits.Measure, clbit::Integer, ::Integer, p::Integer)
    QC.sMZ(p, clbit)
end

function apply!(state::QC.Register, ::MonitoredQuantumCircuits.Measure, qubits::Integer, clbit::Integer, p::Integer)
    QC.apply!(state, QC.sMZ(p, clbit))
end
