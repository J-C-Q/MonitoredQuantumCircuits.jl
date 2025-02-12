function apply!(qc::Circuit, operation::MQC.Weak_ZZ, clbit::Integer, p1::Integer, p2::Integer)
    ax = nQubits(qc) + clbit
    qc.reset(ax - 1)
    qc.h(ax - 1)
    qc.rzz(operation.t_A * 2, p1 - 1, ax - 1)
    qc.rzz(operation.t_B * 2, p2 - 1, ax - 1)
    qc.h(ax - 1)
    qc.measure(ax - 1, clbit - 1)
end
