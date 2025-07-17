
function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.X,
    p::Integer)
    qc = get_circuit(backend)
    qc.x(p - 1)
    return qc
end
