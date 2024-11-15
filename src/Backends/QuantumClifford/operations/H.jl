function depth(::MonitoredQuantumCircuits.H, ::Type{Circuit})
    return 1
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.H, pos::Integer, p::Integer)
    qc.operations[pos] = QC.sHadamard(p)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.H, pos::Integer, step::Integer, p::Integer)
    apply!(qc, MonitoredQuantumCircuits.H(), pos::Integer, Val(step), p)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.H, pos::Integer, ::Val{1}, p::Integer)
    qc.operations[pos] = QC.sHadamard(p)
end

function apply!(::MonitoredQuantumCircuits.H, p::Integer)
    QC.sHadamard(p)
end

function apply!(state::QC.Register, ::MonitoredQuantumCircuits.H, qubits::Integer, clbit::Integer, p::Integer)
    QC.apply!(state, QC.sHadamard(p))
end
