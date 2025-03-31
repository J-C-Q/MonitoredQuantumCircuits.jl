function apply!(qc::Circuit, ::MQC.CNOT, p::SubArray, ::Integer)
    p1 = p[1]
    p2 = p[2]
    qc.cx(p1 - 1, p2 - 1)
end
