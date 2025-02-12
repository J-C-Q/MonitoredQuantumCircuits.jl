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
    QC.project!(state, operator, keep_result)
end
