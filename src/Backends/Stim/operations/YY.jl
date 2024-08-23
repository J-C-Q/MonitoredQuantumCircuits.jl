function depth(::MonitoredQuantumCircuits.YY, ::Type{StimCircuit})
    return 1
end


function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.YY, p1::Integer, p2::Integer, p3::Integer)

    # qc.append("R", p2 - 1)
    # qc.append("S_DAG", p2 - 1)
    # qc.append("CX", [p2 - 1, p1 - 1])
    # qc.append("CX", [p2 - 1, p3 - 1])
    # qc.append("H", p2 - 1)
    # qc.append("M", p2 - 1)

    qc.append("MYY", [p1 - 1, p3 - 1])
end

function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.YY, step::Integer, p1::Integer, p2::Integer, p3::Integer)
    apply!(qc, MonitoredQuantumCircuits.YY(), Val(step), p1, p2, p3)
end


function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.YY, ::Val{1}, p1::Integer, ::Integer, p3::Integer)
    qc.append("MYY", [p1 - 1, p3 - 1])
end
# function apply!(qc::StimCircuit, ::YY, ::Val{1}, ::Integer, p2::Integer, ::Integer)
#     qc.append("R", p2 - 1)
# end
# function apply!(qc::StimCircuit, ::YY, ::Val{2}, ::Integer, p2::Integer, ::Integer)
#     qc.append("S_DAG", p2 - 1)
# end
# function apply!(qc::StimCircuit, ::YY, ::Val{3}, p1::Integer, p2::Integer, ::Integer)
#     qc.append("CX", [p2 - 1, p1 - 1])
# end
# function apply!(qc::StimCircuit, ::YY, ::Val{4}, ::Integer, p2::Integer, p3::Integer)
#     qc.append("CX", [p2 - 1, p3 - 1])
# end
# function apply!(qc::StimCircuit, ::YY, ::Val{5}, ::Integer, p2::Integer, ::Integer)
#     qc.append("H", p2 - 1)
# end
# function apply!(qc::StimCircuit, ::YY, ::Val{6}, ::Integer, p2::Integer, ::Integer)
#     qc.append("M", p2 - 1)
# end
