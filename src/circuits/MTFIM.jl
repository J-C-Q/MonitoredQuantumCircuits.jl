function monitoredTransverseFieldIsing!(
    backend::Backend, geometry::ChainGeometry{Periodic},
    p::Float64; depth=100, keep_result=false, phases=false)

    for i in 1:depth
        if i%2 == 1
            for position in bonds(geometry)
                if rand() >= p
                    apply!(backend, MZZ(), position; keep_result, phases)
                end
            end
        else
           for position in qubits(geometry)
                if rand() < p
                    apply!(backend, MX(), position; keep_result, phases)
                end
            end
        end
    end
    return backend
end
