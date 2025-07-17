
function MQC.apply!(
    backend::Union{AerSimulator,IBMBackend},
    ::MQC.Z,
    p::Integer)
    qc = get_circuit(backend)
    qc.z(p - 1)
    return qc
end
