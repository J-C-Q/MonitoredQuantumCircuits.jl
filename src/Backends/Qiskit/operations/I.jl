function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.I,
    p::Integer)
    qc = get_circuit(backend)
    qc.id(p - 1)
    return qc
end
