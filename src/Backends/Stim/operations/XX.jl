function depth(::MonitoredQuantumCircuits.XX, ::Type{StimCircuit})
    return 1
end

function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.XX, p1::Integer, p2::Integer, p3::Integer)

    # qc.append("R", p2 - 1)
    # ac.append("H", p2 - 1)
    # qc.append("CX", [p2 - 1, p1 - 1])
    # qc.append("CX", [p2 - 1, p3 - 1])
    # qc.append("H", p2 - 1)
    # qc.append("M", p2 - 1)


    qc.append("MXX", [p1 - 1, p3 - 1])
end

function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.XX, step::Integer, p1::Integer, p2::Integer, p3::Integer)
    apply!(qc, MonitoredQuantumCircuits.XX(), Val(step), p1, p2, p3)
end

function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.XX, ::Val{1}, p1::Integer, ::Integer, p3::Integer)
    qc.append("MXX", [p1 - 1, p3 - 1])
end
# function apply!(qc::StimCircuit, ::XX, ::Val{1}, ::Integer, p2::Integer, ::Integer)
#     qc.append("R", p2 - 1)
# end
# function apply!(qc::StimCircuit, ::XX, ::Val{2}, ::Integer, p2::Integer, ::Integer)
#     qc.append("H", p2 - 1)
# end
# function apply!(qc::StimCircuit, ::XX, ::Val{3}, p1::Integer, p2::Integer, ::Integer)
#     qc.append("CX", [p2 - 1, p1 - 1])
# end
# function apply!(qc::StimCircuit, ::XX, ::Val{4}, ::Integer, p2::Integer, p3::Integer)
#     qc.append("CX", [p2 - 1, p3 - 1])
# end
# function apply!(qc::StimCircuit, ::XX, ::Val{5}, ::Integer, p2::Integer, ::Integer)
#     qc.append("H", p2 - 1)
# end
# function apply!(qc::StimCircuit, ::XX, ::Val{6}, ::Integer, p2::Integer, ::Integer)
#     qc.append("M", p2 - 1)
# end
