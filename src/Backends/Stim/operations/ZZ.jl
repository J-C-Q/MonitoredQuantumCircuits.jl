function depth(::MonitoredQuantumCircuits.ZZ, ::Type{StimCircuit})
    return 1
end


function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.ZZ, p1::Integer, p2::Integer, p3::Integer)
    # qc.append("R", p2 - 1)
    # qc.append("CX", [p1 - 1, p2 - 1])
    # qc.append("CX", [p3 - 1, p2 - 1])
    # qc.append("M", p2 - 1)
    qc.append("MZZ", [p1 - 1, p3 - 1])
end
function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.ZZ, step::Integer, p1::Integer, p2::Integer, p3::Integer)
    apply!(qc, MonitoredQuantumCircuits.ZZ(), Val(step), p1, p2, p3)
end
function apply!(qc::StimCircuit, ::MonitoredQuantumCircuits.ZZ, ::Val{1}, p1::Integer, ::Integer, p3::Integer)
    qc.append("MZZ", [p1 - 1, p3 - 1])
end

# function apply!(qc::StimCircuit, ::ZZ, ::Val{1}, ::Integer, p2::Integer, ::Integer)
#     qc.append("R", p2 - 1)
# end
# function apply!(qc::StimCircuit, ::ZZ, ::Val{2}, p1::Integer, p2::Integer, ::Integer)
#     qc.append("CX", [p1 - 1, p2 - 1])
# end
# function apply!(qc::StimCircuit, ::ZZ, ::Val{3}, ::Integer, p2::Integer, p3::Integer)
#     qc.append("CX", [p3 - 1, p2 - 1])
# end
# function apply!(qc::StimCircuit, ::ZZ, ::Val{4}, ::Integer, p2::Integer, ::Integer)
#     qc.append("M", p2 - 1)
# end
