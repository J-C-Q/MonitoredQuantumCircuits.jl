# function apply!(qc::Circuit, ::MQC.CNOT, p::SubArray, ::Integer)
#     p1 = p[1]
#     p2 = p[2]
#     qc.cx(p1 - 1, p2 - 1)
# end

function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.CNOT,
    p1::Integer,
    p2::Integer)
    qc = get_circuit(backend)
    qc.cx(p1 - 1, p2 - 1)
    return qc
end
