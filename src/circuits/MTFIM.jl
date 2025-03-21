function MonitoredTransverseFieldIsing(geometry::ChainGeometry{Periodic}, p::Float64; depth=100)
    circuit = Circuit(geometry)

    X_random = DistributedOperation(Measure_X(), MonitoredQuantumCircuits.qubits(geometry), p)

    ZZ_random = DistributedOperation(ZZ(), bonds(geometry), 1 - p)

    for _ in 1:depth
        apply!(circuit, ZZ_random)
        apply!(circuit, X_random)
    end
    apply!(circuit, ZZ_random)
    return circuit
end
