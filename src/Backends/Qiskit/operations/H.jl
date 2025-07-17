# function apply!(qc::Circuit, ::MQC.H, p::SubArray, ::Integer)
#     p1 = p[1]
#     qc.h(p1 - 1)
# end

function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.H,
    p::Integer)
    qc = get_circuit(backend)
    qc.h(p - 1)
    return qc
end
