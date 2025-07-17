# function apply!(qc::Circuit, ::MQC.I, p::SubArray, ::Integer)
#     p1 = p[1]
#     qc.id(p1 - 1)
# end

function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.I,
    p::Integer)
    qc = get_circuit(backend)
    qc.id(p - 1)
    return qc
end
