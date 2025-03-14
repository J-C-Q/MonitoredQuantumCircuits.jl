function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    ::MonitoredQuantumCircuits.ZZ,
    p1::Integer,
    p2::Integer;
    keep_result::Bool=false)

    operator = simulator.pauli_operator
    QC.zero!(operator)
    operator[p1] = (false, true) #Z
    operator[p2] = (false, true) #Z
    QC.project!(state, operator; keep_result)
end


function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    ::Type{MonitoredQuantumCircuits.ZZ},
    floatParamter,
    intParameter,
    p1::Integer,
    p2::Integer;
    keep_result::Bool=false)

    operator = simulator.pauli_operator
    QC.zero!(operator)
    operator[p1] = (false, true) #Z
    operator[p2] = (false, true) #Z
    QC.project!(state, operator; keep_result)
end


function apply_ZZ!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    p1::Integer,
    p2::Integer,
    keep_result::Bool=false)

    operator = simulator.pauli_operator
    QC.zero!(operator)
    operator[p1] = (false, true) #Z
    operator[p2] = (false, true) #Z
    QC.project!(state, operator; keep_result)
end

function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    ::MonitoredQuantumCircuits.ZZ,
    p;
    keep_result::Bool=false)

    operator = simulator.pauli_operator
    QC.zero!(operator)
    operator[p[1]] = (false, true) #Z
    operator[p[2]] = (false, true) #Z
    QC.project!(state, operator; keep_result)
end
