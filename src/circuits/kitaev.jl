function MeasurementOnlyKitaev(geometry::HoneycombGeometry{Periodic}, px::Float64, py::Float64, pz::Float64; depth::Integer=100)
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
    push!(randomPartityMeasurement, XX(), bonds(geometry; kitaevType=:X); probability=px)
    push!(randomPartityMeasurement, YY(), bonds(geometry; kitaevType=:Y); probability=py)
    push!(randomPartityMeasurement, ZZ(), bonds(geometry; kitaevType=:Z); probability=pz)
    for _ in 1:depth*nQubits(geometry)
        apply!(circuit, randomPartityMeasurement)
    end
    return circuit
end
