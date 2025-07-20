function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.MYY,
    p1::Integer,
    p2::Integer;
    ancilla=aux(backend),
    kwargs...)

    ax = ancilla - 1
    p1 = p1 - 1
    p2 = p2 - 1
    qc = get_circuit(backend)
    qc.reset(ax)
    qc.h(ax)
    qc.sdg(p1)
    qc.sdg(p2)
    qc.cx(ax, p1)
    qc.cx(ax, p2)
    qc.s(p1)
    qc.s(p2)
    qc.h(ax)
    qc.measure(ax, ax)
    measured_qubits = get_measured_qubits(backend)
    push!(measured_qubits, ax)
    return qc
end

function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.MYY,
    b::MQC.Bond;
    ancilla=aux(backend),
    kwargs...)

    ax = ancilla - 1
    p1 = b.qubit1 - 1
    p2 = b.qubit2 - 1
    qc = get_circuit(backend)
    qc.reset(ax)
    qc.h(ax)
    qc.sdg(p1)
    qc.sdg(p2)
    qc.cx(ax, p1)
    qc.cx(ax, p2)
    qc.s(p1)
    qc.s(p2)
    qc.h(ax)
    qc.measure(ax, ax)
    measured_qubits = get_measured_qubits(backend)
    push!(measured_qubits, ax+1)
    return qc
end
