function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.CNOT,
    p1::Integer,
    p2::Integer)
    qc = get_circuit(backend)
    qc.cx(p1 - 1, p2 - 1)
    return qc
end
