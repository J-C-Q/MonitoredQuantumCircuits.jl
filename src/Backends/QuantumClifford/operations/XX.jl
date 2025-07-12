include("../util/fastXX.jl")
function apply!(
    register::QC.Register,
    simulator::TableauSimulator,
    ::MonitoredQuantumCircuits.XX,
    p)

    # operator = simulator.pauli_operator
    # QC.zero!(operator)
    # operator[p[1]] = (true, false) #X
    # operator[p[2]] = (true, false) #X
    # _, res = QC.projectrand!(register, operator)
    _, res = projectXXrand!(register.stab, p[1], p[2])
    push!(register.bits, res / 2)
end


function expr_apply!(
    ::MonitoredQuantumCircuits.XX
)
    block_ex = quote
        operator = simulator.pauli_operator
        QuantumClifford.QC.zero!(operator)
        operator[p[1]] = (true, false) #Z
        operator[p[2]] = (true, false) #Z
        _, res = QuantumClifford.QC.projectrand!(register, operator)
        push!(register.bits, res / 2)
    end
    return block_ex
end
