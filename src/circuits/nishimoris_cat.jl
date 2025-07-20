function monitoredGHZ!(
    backend::Backend, geometry::IBMQ_Falcon;
    tApi::Float64=1/4)

    for position in qubits(geometry)
        apply!(backend, H(), position)
    end
    for (i,position) in enumerate(bonds(geometry))
        apply!(backend, MZZ(π * tApi), position; ancilla=nQubits(geometry)+i)
    end
    for position in qubits(geometry)
        apply!(backend, MZ(), position)
    end
    return backend
end
