function depth(::MonitoredQuantumCircuits.Measure, ::Type{Circuit})
    return 1
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.Measure, clbit::Integer, p::Integer)
    push!(qc, QC.sMZ(p, clbit))
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.Measure, step::Integer, clbit::Integer, p::Integer)
    apply!(qc, MonitoredQuantumCircuits.Measure(), Val(step), clbit, p)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.Measure, ::Val{1}, clbit::Integer, p::Integer)
    push!(qc, QC.sMZ(p, clbit))
end
