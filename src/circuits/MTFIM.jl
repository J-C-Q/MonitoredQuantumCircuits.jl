function monitoredTransverseFieldIsing!(
    backend::Backend, geometry::ChainGeometry{Periodic},
    p::Float64; depth=100, keep_result=false)

    qubits_ = qubits(geometry)
    bonds_ = bonds(geometry)
    for i in 1:depth
        if i%2 == 1
            for position in eachcol(bonds_)
                if rand() >= p
                    apply!(backend, ZZ(), position...; keep_result)
                end
            end
        else
           for position in eachcol(qubits_)
                if rand() < p
                    apply!(backend, Measure_X(), position...; keep_result)
                end
            end
        end
    end
    return backend
end
