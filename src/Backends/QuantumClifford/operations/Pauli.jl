function apply!(state::QC.MixedDestabilizer, p::MonitoredQuantumCircuits.nPauli, pos::Vararg{Integer})

    QC.project!(state, QC.embed(state.tab.nqubits, pos, QC.PauliOperator(p.xs, p.zs)), keep_result=false)
end


function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    ::MonitoredQuantumCircuits.nPauli,
    p::Vararg{Integer};
    keep_result::Bool=false)

    operator = simulator.pauli_operator
    QC.zero!(operator)
    QC.xview(operator) .= p.xs
    QC.zview(operator) .= p.zs
    QC.project!(state, operator, keep_result)
end
