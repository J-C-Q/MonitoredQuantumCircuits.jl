function apply!(qc::Circuit, ::MQC.ZZ, p::SubArray, ancilla::Integer)
    ax = ancilla
    p1 = p[1]
    p2 = p[2]
    qc.reset(ax - 1)
    qc.cx(p1 - 1, ax - 1)
    qc.cx(p2 - 1, ax - 1)
    qc.measure(ax - 1, ax - 1)
end
