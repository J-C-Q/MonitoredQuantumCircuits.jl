function apply!(qc::Circuit, ::MQC.H, p::SubArray, ::Integer)
    p1 = p[1]
    qc.h(p1 - 1)
end
