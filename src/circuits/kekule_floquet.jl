function MeasurementOnlyKekule_Floquet(geometry::HoneycombGeometry{Periodic}; depth::Integer=100)
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

    # fb

    for _ in 1:depth
        for position in eachcol(bonds(geometry; kekuleType=:Red))
            apply!(circuit, ZZ(), position...)
        end
        for position in eachcol(bonds(geometry; kekuleType=:Green))
            apply!(circuit, YY(), position...)
        end
        for position in eachcol(bonds(geometry; kekuleType=:Blue))
            apply!(circuit, XX(), position...)
        end
    end
    return circuit
end
