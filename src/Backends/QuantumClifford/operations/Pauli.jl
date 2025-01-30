function apply!(state::QC.MixedDestabilizer, p::MonitoredQuantumCircuits.nPauli, pos::Vararg{Integer})

    QC.project!(state, QC.embed(state.tab.nqubits, pos, QC.PauliOperator(p.xs, p.zs)), keep_result=false)
end
