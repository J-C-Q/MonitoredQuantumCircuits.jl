function apply!(qc::Circuit, operation::MQC.NPauli, p::SubArray, ancilla::Integer)
    ax = ancilla - 1
    qc.reset(ax)
    qc.h(ax)
    for (i, parameter) in enumerate(operation.memory)
        pos = p[i] - 1
        if parameter == 1
            qc.h(pos)
        elseif parameter == 2
            qc.sdg(pos)
            qc.h(pos)
        end
        qc.cx(ax, pos)
        if parameter == 1
            qc.h(pos)
        elseif parameter == 2
            qc.s(pos)
            qc.h(pos)
        end
    end
    qc.h(ax)
    qc.measure(ax, ax)
end
