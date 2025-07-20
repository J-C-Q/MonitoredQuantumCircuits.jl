function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.Y,
    p::Integer)
    qc = get_circuit(backend)
    qc.y(p - 1)
    return qc
end
