include("../util/fastZZ.jl")
function apply!(
    register::QC.Register,
    simulator::TableauSimulator,
    ::MonitoredQuantumCircuits.ZZ,
    p)

    # operator = simulator.pauli_operator
    # QC.zero!(operator)
    # operator[p[1]] = (false, true) #Z
    # operator[p[2]] = (false, true) #Z
    # _, res = QC.projectrand!(register, operator)
    _, res = projectZZrand!(register.stab, p[1], p[2])
    push!(register.bits, res / 2)
end


function expr_apply!(
    ::MonitoredQuantumCircuits.ZZ
)
    block_ex = quote
        operator = simulator.pauli_operator
        QuantumClifford.QC.zero!(operator)
        operator[p[1]] = (false, true) #Z
        operator[p[2]] = (false, true) #Z
        _, res = QuantumClifford.QC.projectrand!(register, operator)
        push!(register.bits, res / 2)
    end
    return block_ex
end
