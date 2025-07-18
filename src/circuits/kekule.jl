function measurementOnlyKekule!(backend::Backend,geometry::HoneycombGeometry{Periodic}, pr::Float64, pg::Float64, pb::Float64; depth::Integer=100,keep_result=false)

    for position in eachcol(bonds(geometry; kitaevType=:Z))
        apply!(backend, ZZ(), position...; keep_result)
    end
    for position in eachcol(plaquettes(geometry))
        apply!(backend, NPauli(Y, X, Z, Y, X, Z), position...; keep_result)
    end
    xy_loop = loops(geometry; kitaevTypes=(:X, :Y))[:, 1]
    xz_loop = loops(geometry; kitaevTypes=(:X, :Z))[:, 1]
    apply!(backend, NPauli(Z(), length(xy_loop)), xy_loop...; keep_result)
    apply!(backend, NPauli(Y(), length(xy_loop)), xz_loop...; keep_result)
    for i in 1:depth*nQubits(geometry)
        p = rand()
        if p < pr
            bond = random_bond(geometry; type=:Red)

        elseif p < pr + pg
            bond = random_bond(geometry; type=:Green)
        else
            bond = random_bond(geometry; type=:Blue)
        end
        if isKitaevX(geometry, bond)
            apply!(backend, XX(), bond...; keep_result)
        elseif isKitaevY(geometry, bond)
            apply!(backend, YY(), bond...; keep_result)
        else
            apply!(backend, ZZ(), bond...; keep_result)
        end
    end
    return backend
end
