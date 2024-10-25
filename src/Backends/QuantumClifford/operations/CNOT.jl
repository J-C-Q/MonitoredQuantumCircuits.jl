function depth(::MonitoredQuantumCircuits.CNOT, ::Type{Circuit})
    return 1
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.CNOT, p1::Integer, p2::Integer)
    push!(qc, QC.sCNOT(p1, p2))
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.CNOT, step::Integer, p1::Integer, p2::Integer)
    apply!(qc, MonitoredQuantumCircuits.CNOT(), Val(step), p1, p2)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.CNOT, ::Val{1}, p1::Integer, p2::Integer)
    push!(qc, QC.sCNOT(p1, p2))
end
