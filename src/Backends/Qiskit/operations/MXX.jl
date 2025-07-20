function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.MXX,
    p1::Integer,
    p2::Integer;
    ancilla=aux(backend),
    kwargs...)

    ax = ancilla
    qc = get_circuit(backend)
    qc.reset(ax - 1)
    qc.h(ax - 1)
    qc.cx(ax - 1, p1 - 1)
    qc.cx(ax - 1, p2 - 1)
    qc.h(ax - 1)
    qc.measure(ax - 1, ax - 1)
    measured_qubits = get_measured_qubits(backend)
    push!(measured_qubits, ax)
    return qc
end

function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.MXX,
    b::MQC.Bond;
    ancilla=aux(backend),
    kwargs...)

    p1 = b.qubit1
    p2 = b.qubit2
    ax = ancilla
    qc = get_circuit(backend)
    qc.reset(ax - 1)
    qc.h(ax - 1)
    qc.cx(ax - 1, p1 - 1)
    qc.cx(ax - 1, p2 - 1)
    qc.h(ax - 1)
    qc.measure(ax - 1, ax - 1)
    measured_qubits = get_measured_qubits(backend)
    push!(measured_qubits, ax)
    return qc
end
