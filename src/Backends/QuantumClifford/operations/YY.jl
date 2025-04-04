function apply!(state::QC.MixedDestabilizer, ::MonitoredQuantumCircuits.YY, p1::Integer, p2::Integer)
    QC.project!(state, QC.embed(state.tab.nqubits, (p1, p2), QC.P"YY"), keep_result=false)
end

function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    ::MonitoredQuantumCircuits.YY,
    p1::Integer,
    p2::Integer;
    keep_result::Bool=false)

    operator = simulator.pauli_operator
    QC.zero!(operator)
    operator[p1] = (true, true) #Y
    operator[p2] = (true, true) #Y
    QC.project!(state, operator; keep_result)
end

function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    ::Type{MonitoredQuantumCircuits.YY},
    floatParamter,
    intParameter,
    p1::Integer,
    p2::Integer;
    keep_result::Bool=false)

    operator = simulator.pauli_operator
    QC.zero!(operator)
    operator[p1] = (true, true) #Y
    operator[p2] = (true, true) #Y
    QC.project!(state, operator; keep_result)
end

function apply_YY!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    p1::Integer,
    p2::Integer,
    keep_result::Bool=false)

    operator = simulator.pauli_operator
    QC.zero!(operator)
    operator[p1] = (true, true) #Y
    operator[p2] = (true, true) #Y
    QC.project!(state, operator; keep_result)
end

function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    ::MonitoredQuantumCircuits.YY,
    p;
    keep_result::Bool=false)

    operator = simulator.pauli_operator
    QC.zero!(operator)
    operator[p[1]] = (true, true) #Y
    operator[p[2]] = (true, true) #Y
    QC.project!(state, operator; keep_result)
end
