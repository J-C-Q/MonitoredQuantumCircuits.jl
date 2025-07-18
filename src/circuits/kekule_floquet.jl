function measurementOnlyKekule_Floquet!(backend::Backend,geometry::HoneycombGeometry{Periodic}; depth::Integer=100)
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
    for i in 1:depth
        for position in eachcol(bonds(geometry; kekuleType=:Red))
            apply!(backend, ZZ(), position...)
        end
        for position in eachcol(bonds(geometry; kekuleType=:Green))
            apply!(backend, YY(), position...)
        end
        for position in eachcol(bonds(geometry; kekuleType=:Blue))
            apply!(backend, XX(), position...)
        end
    end
    return backend
end
