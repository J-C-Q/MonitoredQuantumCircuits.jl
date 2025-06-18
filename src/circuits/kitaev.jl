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
    randomParityMeasurement = RandomOperation()
    push!(randomParityMeasurement, XX(), bonds(geometry; kitaevType=:X); probability=px)
    push!(randomParityMeasurement, YY(), bonds(geometry; kitaevType=:Y); probability=py)
    push!(randomParityMeasurement, ZZ(), bonds(geometry; kitaevType=:Z); probability=pz)
    for i in 1:depth*nQubits(geometry)
        apply!(circuit, randomParityMeasurement)
    end

    return circuit
end
