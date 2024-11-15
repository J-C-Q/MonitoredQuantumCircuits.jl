function depth(::MonitoredQuantumCircuits.H, ::Type{Circuit})
    return 1
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.H, p::Integer)
    push!(qc, QC.sHadamard(p))
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.H, step::Integer, p::Integer)
    apply!(qc, MonitoredQuantumCircuits.H(), Val(step), p)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.H, ::Val{1}, p::Integer)
    push!(qc, QC.sHadamard(p))
end
