function apply!(qc::Circuit, operation::MQC.Weak_XX, p::SubArray, ancilla::Integer)
    ax = ancilla - 1
    p1 = p[1] - 1
    p2 = p[2] - 1
    qc.reset(ax)
    qc.h(p1)
    qc.h(ax)
    qc.h(p2)
    qc.rzz(π / 2, p1, ax)
    qc.rzz(operation.t * 2, p2, ax)
    qc.h(p1)
    qc.h(ax)
    qc.h(p2)
    qc.measure(ax, ax)
    qc.x(p1).c_if(ax)
end
