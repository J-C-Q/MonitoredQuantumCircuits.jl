function apply!(state::QC.MixedDestabilizer, p::MonitoredQuantumCircuits.nPauli, pos::Vararg{Integer})

    QC.project!(state, QC.embed(state.tab.nqubits, pos, QC.PauliOperator(p.xs, p.zs)), keep_result=false)
end


function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    P::MonitoredQuantumCircuits.nPauli,
    p::Vararg{Integer};
    keep_result::Bool=false)

    operator = simulator.pauli_operator
    QC.zero!(operator)
    for (i, pos) in enumerate(p)
        operator[pos] = (P.xs[i], P.zs[i])
    end
    QC.project!(state, operator; keep_result)
end
