function apply!(qc::Circuit, ::MQC.ZZ, clbit::Integer, p1::Integer, p2::Integer)
    ax = nQubits(qc) + clbit
    qc.reset(ax - 1)
    qc.cx(p1 - 1, ax - 1)
    qc.cx(p2 - 1, ax - 1)
    qc.measure(ax - 1, clbit - 1)
end
