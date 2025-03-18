function MeasurementOnlyKekule(geometry::HoneycombGeometry{Periodic}, pr::Float64, pg::Float64, pb::Float64; depth::Integer=100)
    circuit = Circuit(geometry)

    for position in eachcol(bonds(geometry; kitaevType=:Z))
        apply!(circuit, ZZ(), position...)
    end
    for position in eachcol(plaquettes(geometry))
        apply!(circuit, NPauli(Y, X, Z, Y, X, Z), position...)
    end
    xy_loop = loops(geometry; kitaevTypes=(:X, :Y))[:, 1]
    xz_loop = loops(geometry; kitaevTypes=(:X, :Z))[:, 1]
    apply!(circuit, NPauli(Z(), length(xy_loop)), xy_loop...)
    apply!(circuit, NPauli(Y(), length(xy_loop)), xz_loop...)
    randomPartityMeasurement = RandomOperation()
    push!(randomPartityMeasurement, XX(), bonds(geometry; kitaevType=:X, kekuleType=:Red); probability=pr / 3)
    push!(randomPartityMeasurement, YY(), bonds(geometry; kitaevType=:Y, kekuleType=:Red); probability=pr / 3)
    push!(randomPartityMeasurement, ZZ(), bonds(geometry; kitaevType=:Z, kekuleType=:Red); probability=pr / 3)
    push!(randomPartityMeasurement, XX(), bonds(geometry; kitaevType=:X, kekuleType=:Green); probability=pg / 3)
    push!(randomPartityMeasurement, YY(), bonds(geometry; kitaevType=:Y, kekuleType=:Green); probability=pg / 3)
    push!(randomPartityMeasurement, ZZ(), bonds(geometry; kitaevType=:Z, kekuleType=:Green); probability=pg / 3)
    push!(randomPartityMeasurement, XX(), bonds(geometry; kitaevType=:X, kekuleType=:Blue); probability=pb / 3)
    push!(randomPartityMeasurement, YY(), bonds(geometry; kitaevType=:Y, kekuleType=:Blue); probability=pb / 3)
    push!(randomPartityMeasurement, ZZ(), bonds(geometry; kitaevType=:Z, kekuleType=:Blue); probability=pb / 3)
    for _ in 1:depth*nQubits(geometry)
        apply!(circuit, randomPartityMeasurement)
    end
    return circuit
end
