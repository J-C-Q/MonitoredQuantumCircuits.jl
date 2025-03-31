function apply!(qc::Circuit, ::MQC.I, p::SubArray, ::Integer)
    p1 = p[1]
    qc.id(p1 - 1)
end
