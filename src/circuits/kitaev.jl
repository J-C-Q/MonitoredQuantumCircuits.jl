function MeasurementOnlyKitaev(backend::Backend, geometry::HoneycombGeometry{Periodic}, px::Float64, py::Float64, pz::Float64; depth::Integer=100,keep_result=false)

    for position in eachcol(bonds(geometry; kitaevType=:Z))
        apply!(backend, ZZ(), position...;keep_result)
    end
    for position in eachcol(plaquettes(geometry))
        apply!(backend, NPauli(Y, X, Z, Y, X, Z), position...;keep_result)
    end
    xy_loop = loops(geometry; kitaevTypes=(:X, :Y))[:, 1]
    xz_loop = loops(geometry; kitaevTypes=(:X, :Z))[:, 1]
    apply!(backend, NPauli(Z(), length(xy_loop)), xy_loop...;keep_result)
    apply!(backend, NPauli(Y(), length(xy_loop)), xz_loop...;keep_result)
    for i in 1:depth*nQubits(geometry)
        p = rand()
        if p < px
            apply!(backend, XX(), random_bond(geometry; type=:X)...; keep_result)
        elseif p < px + py
            apply!(backend, YY(), random_bond(geometry; type=:Y)...; keep_result)
        else
            apply!(backend, ZZ(), random_bond(geometry; type=:Z)...; keep_result)
        end
    end
    return execute(backend)
end
