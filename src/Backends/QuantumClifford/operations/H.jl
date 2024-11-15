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
