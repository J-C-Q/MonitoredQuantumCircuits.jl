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
