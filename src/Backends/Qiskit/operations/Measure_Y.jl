function apply!(qc::Circuit, ::MQC.Measure_Y, p::SubArray, ::Integer)
    p1 = p[1]
    qc.sdg(p1 - 1)
    qc.h(p1 - 1)
    qc.measure(p1 - 1, p1 - 1)
end
