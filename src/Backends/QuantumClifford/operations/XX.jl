function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    ::MonitoredQuantumCircuits.XX,
    p1::Integer,
    p2::Integer;
    keep_result::Bool=false)

    operator = simulator.pauli_operator
    QC.zero!(operator)
    operator[p1] = (true, false) #X
    operator[p2] = (true, false) #X
    QC.project!(state, operator; keep_result)
end


function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    ::Type{MonitoredQuantumCircuits.XX},
    floatParamter,
    intParameter,
    p1::Integer,
    p2::Integer;
    keep_result::Bool=false)
    operator = simulator.pauli_operator
    QC.zero!(operator)
    operator[p1] = (true, false) #X
    operator[p2] = (true, false) #X
    QC.project!(state, operator; keep_result)
end

function apply_XX!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    p1::Integer,
    p2::Integer,
    keep_result::Bool=false)
    operator = simulator.pauli_operator
    QC.zero!(operator)
    operator[p1] = (true, false) #X
    operator[p2] = (true, false) #X
    QC.project!(state, operator; keep_result)
end

function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    ::MonitoredQuantumCircuits.XX,
    p;
    keep_result::Bool=false)

    operator = simulator.pauli_operator
    QC.zero!(operator)
    operator[p[1]] = (true, false) #X
    operator[p[2]] = (true, false) #X
    QC.project!(state, operator; keep_result)
end
