function apply!(qc::Circuit, ::MQC.YY, clbit::Integer, p1::Integer, p2::Integer)
    ax = nQubits(qc) + clbit
    qc.reset(ax - 1)
    qc.sdg(ax - 1)
    qc.cx(ax - 1, p1 - 1)
    qc.cx(ax - 1, p2 - 1)
    qc.h(ax - 1)
    qc.measure(ax - 1, clbit - 1)
end
