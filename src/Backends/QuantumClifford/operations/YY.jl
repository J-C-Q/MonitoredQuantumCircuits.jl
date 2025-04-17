function apply!(
    register::QC.Register,
    simulator::TableauSimulator,
    ::MonitoredQuantumCircuits.YY,
    p)

    operator = simulator.pauli_operator
    QC.zero!(operator)
    operator[p[1]] = (true, true) #Y
    operator[p[2]] = (true, true) #Y
    _, res = QC.projectrand!(register, operator)
    push!(register.bits, res / 2)
end

function expr_apply!(
    ::MonitoredQuantumCircuits.YY
)
    block_ex = quote
        operator = simulator.pauli_operator
        QuantumClifford.QC.zero!(operator)
        operator[p[1]] = (true, true) #Z
        operator[p[2]] = (true, true) #Z
        _, res = QuantumClifford.QC.projectrand!(register, operator)
        push!(register.bits, res / 2)
    end
    return block_ex
end
