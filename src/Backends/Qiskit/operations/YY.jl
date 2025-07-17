# function apply!(qc::Circuit, ::MQC.YY, p::SubArray, ancilla::Integer)
#     ax = ancilla - 1
#     p1 = p[1] - 1
#     p2 = p[2] - 1
#     qc.reset(ax)
#     qc.h(ax)
#     qc.sdg(p1)
#     qc.sdg(p2)
#     qc.cx(ax, p1)
#     qc.cx(ax, p2)
#     qc.s(p1)
#     qc.s(p2)
#     qc.h(ax)
#     qc.measure(ax, ax)
# end


function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.YY,
    p1::Integer,
    p2::Integer;
    ancilla=aux(backend),
    kwargs...)

    ax = ancilla - 1
    p1 = p1 - 1
    p2 = p2 - 1
    qc = get_circuit(backend)
    qc.reset(ax)
    qc.h(ax)
    qc.sdg(p1)
    qc.sdg(p2)
    qc.cx(ax, p1)
    qc.cx(ax, p2)
    qc.s(p1)
    qc.s(p2)
    qc.h(ax)
    qc.measure(ax, ax)
    return qc
end
