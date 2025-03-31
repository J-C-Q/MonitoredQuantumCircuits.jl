function apply!(qc::Circuit, ::MQC.Measure_Z, p::SubArray, ::Integer)
    p1 = p[1]
    qc.measure(p1 - 1, p1 - 1)
end
