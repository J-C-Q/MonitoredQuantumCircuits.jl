function apply!(qc::Circuit, operation::MQC.Weak_ZZ, p::SubArray, ancilla::Integer)
    ax = ancilla - 1
    p1 = p[1] - 1
    p2 = p[2] - 1
    qc.reset(ax)
    qc.h(ax)
    qc.rzz(π / 2, p1, ax)
    qc.rzz(operation.t * 2, p2, ax)
    qc.h(ax)
    qc.measure(ax, ax)
    # qc.z(p1).c_if(ax)
end
