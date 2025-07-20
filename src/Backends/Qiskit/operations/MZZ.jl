function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.MZZ,
    p1::Integer,
    p2::Integer;
    ancilla=aux(backend),
    kwargs...)

    ax = ancilla
    qc = get_circuit(backend)
    qc.reset(ax - 1)
    qc.cx(p1 - 1, ax - 1)
    qc.cx(p2 - 1, ax - 1)
    qc.measure(ax - 1, ax - 1)
    measured_qubits = get_measured_qubits(backend)
    push!(measured_qubits, ax)
    return qc
end

function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.MZZ,
    b::MQC.Bond;
    ancilla=aux(backend),
    kwargs...)

    ax = ancilla
    p1 = b.qubit1
    p2 = b.qubit2
    qc = get_circuit(backend)
    qc.reset(ax - 1)
    qc.cx(p1 - 1, ax - 1)
    qc.cx(p2 - 1, ax - 1)
    qc.measure(ax - 1, ax - 1)
    measured_qubits = get_measured_qubits(backend)
    push!(measured_qubits, ax)
    return qc
end
