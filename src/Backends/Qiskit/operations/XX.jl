function apply!(qc::Circuit, ::MQC.XX, p::SubArray, ancilla::Integer)
    ax = ancilla
    p1 = p[1]
    p2 = p[2]
    qc.reset(ax - 1)
    qc.h(ax - 1)
    qc.cx(ax - 1, p1 - 1)
    qc.cx(ax - 1, p2 - 1)
    qc.h(ax - 1)
    qc.measure(ax - 1, ax - 1)
end
