function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.H,
    p::Integer)
    qc = get_circuit(backend)
    qc.h(p - 1)
    return qc
end
