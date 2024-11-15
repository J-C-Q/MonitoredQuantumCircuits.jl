function depth(::MonitoredQuantumCircuits.CNOT, ::Type{Circuit})
    return 1
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.CNOT, pos::Integer, p1::Integer, p2::Integer)
    qc.operations[pos] = QC.sCNOT(p1, p2)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.CNOT, pos::Integer, step::Integer, p1::Integer, p2::Integer)
    apply!(qc, MonitoredQuantumCircuits.CNOT(), pos, Val(step), p1, p2)
end

function apply!(qc::Circuit, ::MonitoredQuantumCircuits.CNOT, pos::Integer, ::Val{1}, p1::Integer, p2::Integer)
    qc.operations[pos] = QC.sCNOT(p1, p2)
end


function apply!(::MonitoredQuantumCircuits.CNOT, p1::Integer, p2::Integer)

end
