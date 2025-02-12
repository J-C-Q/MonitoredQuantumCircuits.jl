function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    ::MonitoredQuantumCircuits.Measure,
    p::Integer;
    keep_result::Bool=false)

    operator = simulator.pauli_operator
    QC.zero!(operator)
    operator[p] = (false, true) #Z
    QC.project!(state, operator, keep_result)
end
