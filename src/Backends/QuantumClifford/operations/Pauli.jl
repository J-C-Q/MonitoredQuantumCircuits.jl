function apply!(state::QC.MixedDestabilizer, p::MonitoredQuantumCircuits.NPauli, pos::Vararg{Integer})

    QC.project!(state, QC.embed(state.tab.nqubits, pos, QC.PauliOperator(p.xs, p.zs)), keep_result=false)
end


function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    P::MonitoredQuantumCircuits.NPauli,
    p::Vararg{Integer};
    keep_result::Bool=false)

    operator = simulator.pauli_operator
    QC.zero!(operator)
    for (i, pos) in enumerate(p)
        operator[pos] = (P.xs[i], P.zs[i])
    end
    QC.project!(state, operator; keep_result)
end

function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    ::Type{T},
    floatParamter::SubArray,
    intParameter::SubArray,
    p::Vararg{Integer};
    keep_result::Bool=false) where {T<:MonitoredQuantumCircuits.NPauli}

    options = ((true, false), (true, true), (false, true))
    operator = simulator.pauli_operator
    QC.zero!(operator)
    for (i, parameter) in enumerate(intParameter)
        operator[p[i]] = options[parameter]
    end
    QC.project!(state, operator; keep_result)
end

function apply_NPauli!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    intParameter::SubArray,
    p,
    keep_result::Bool=false)
    options = ((true, false), (true, true), (false, true))
    operator = simulator.pauli_operator
    QC.zero!(operator)
    for (i, parameter) in enumerate(intParameter)
        operator[p[i]] = options[parameter]
    end
    QC.project!(state, operator; keep_result)
end

function apply!(
    state::QC.MixedDestabilizer,
    simulator::TableauSimulator,
    P::MonitoredQuantumCircuits.NPauli,
    p::SubArray;
    keep_result::Bool=false)
    options = ((true, false), (true, true), (false, true))
    operator = simulator.pauli_operator
    QC.zero!(operator)

    for (i, parameter) in enumerate(P.memory)
        operator[p[i]] = options[parameter]
    end

    QC.project!(state, operator; keep_result)
end
