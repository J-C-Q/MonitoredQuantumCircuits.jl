function apply!(
    register::QC.Register,
    simulator::TableauSimulator,
    P::MonitoredQuantumCircuits.NPauli,
    p)

    options = ((true, false), (true, true), (false, true))
    operator = simulator.pauli_operator
    QC.zero!(operator)

    for (i, parameter) in enumerate(P.memory)
        operator[p[i]] = options[parameter]
    end

    _, res = QC.projectrand!(register, operator)
    push!(register.bits, res / 2)
end


function expr_apply!(
    P::MonitoredQuantumCircuits.NPauli
)
    block_ex = quote
        options = ((true, false), (true, true), (false, true))
        operator = simulator.pauli_operator
        QuantumClifford.QC.zero!(operator)
        for (i, parameter) in enumerate($(P.memory))
            operator[p[i]] = options[parameter]
        end
        _, res = QuantumClifford.QC.projectrand!(register, operator)
        push!(register.bits, res / 2)
    end
    return block_ex
end
