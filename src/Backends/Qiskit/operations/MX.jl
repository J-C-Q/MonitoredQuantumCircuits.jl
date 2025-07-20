function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.MX,
    p::Integer;
    kwargs...)
    qc = get_circuit(backend)
    qc.h(p - 1)
    qc.measure(p - 1, p - 1)
    measured_qubits = get_measured_qubits(backend)
    push!(measured_qubits, p)
    return qc
end
