# function apply!(qc::Circuit, ::MQC.Measure_X, p::SubArray, ::Integer)
#     p1 = p[1]
#     qc.h(p1 - 1)
#     qc.measure(p1 - 1, p1 - 1)
# end

function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.Measure_X,
    p::Integer;
    kwargs...)
    qc = get_circuit(backend)
    qc.h(p - 1)
    qc.measure(p - 1, p - 1)
    return qc
end
