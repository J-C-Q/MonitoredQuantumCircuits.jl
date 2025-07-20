function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    operation::MQC.MnPauli{N},
    p::Vararg{Int};
    ancilla=aux(backend),
    kwargs...) where N

    qc = get_circuit(backend)
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
    return qc
end

function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    operation::MQC.MnPauli{N},
    p::SubArray;
    ancilla=aux(backend),
    kwargs...) where N

    qc = get_circuit(backend)
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
    return qc
end
