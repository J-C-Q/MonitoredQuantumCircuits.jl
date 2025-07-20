function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    operation::MQC.WeakMXX,
    p1::Integer,
    p2::Integer;
    ancilla=aux(backend),
    kwargs...)

    qc = get_circuit(backend)
    ax = ancilla - 1
    p1 = p1 - 1
    p2 = p2 - 1
    qc.reset(ax)
    qc.h(p1)
    qc.h(ax)
    qc.h(p2)
    qc.rzz(π / 2, p1, ax)
    qc.rzz(operation.t * 2, p2, ax)
    qc.h(p1)
    qc.h(ax)
    qc.h(p2)
    qc.measure(ax, ax)
    qc.x(p1).c_if(ax,true)
    measured_qubits = get_measured_qubits(backend)
    push!(measured_qubits, ax+1)
    return qc
end

function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    operation::MQC.WeakMXX,
    b::MQC.Bond;
    ancilla=aux(backend),
    kwargs...)

    qc = get_circuit(backend)
    ax = ancilla - 1
    p1 = b.qubit1 - 1
    p2 = b.qubit1 - 1
    qc.reset(ax)
    qc.h(p1)
    qc.h(ax)
    qc.h(p2)
    qc.rzz(π / 2, p1, ax)
    qc.rzz(operation.t * 2, p2, ax)
    qc.h(p1)
    qc.h(ax)
    qc.h(p2)
    qc.measure(ax, ax)
    qc.x(p1).c_if(ax,true)
    measured_qubits = get_measured_qubits(backend)
    push!(measured_qubits, ax+1)
    return qc
end
