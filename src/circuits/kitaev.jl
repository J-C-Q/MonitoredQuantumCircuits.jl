function measurementOnlyKitaev!(
    backend::Backend, geometry::HoneycombGeometry{Periodic},
    px::Float64, py::Float64, pz::Float64;
    depth::Integer=100,keep_result=false,phases=false)

    for position in kitaevZ_bonds(geometry)
        apply!(backend, MZZ(), position; keep_result, phases)
    end
    for position in plaquettes(geometry)
        apply!(backend, MnPauli(Y, X, Z, Y, X, Z), position; keep_result, phases)
    end
    xy_loop = loopsXY(geometry)[1]
    xz_loop = loopsXZ(geometry)[1]
    apply!(backend, MnPauli(Z(), XYlooplength(geometry)), xy_loop; keep_result, phases)
    apply!(backend, MnPauli(Y(), XZlooplength(geometry)), xz_loop; keep_result, phases)
    for i in 1:depth*nQubits(geometry)
        p = rand()
        if p < px
            bond = random_kitaevX_bond(geometry)
            apply!(backend, MXX(), bond; keep_result, phases)
        elseif p < px + py
            bond = random_kitaevY_bond(geometry)
            apply!(backend, MYY(), bond; keep_result, phases)
        else
            bond = random_kitaevZ_bond(geometry)
            apply!(backend, MZZ(), bond; keep_result, phases)
        end
    end
    return backend
end
