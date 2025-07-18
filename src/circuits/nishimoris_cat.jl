function nishimorisCat!(backend::Backend, geometry::HoneycombGeometry{Open};tApi::Float64=1/4)

    bond_index = Dict((min(t...),max(t...)) => i for (i, t) in enumerate(eachcol(bonds(geometry))))
    qubits_ = qubits(geometry)
    for position in eachcol(qubits_)
        apply!(backend, H(), position...)
    end
    for position in eachcol(bonds(geometry; kitaevType=:Z))
        apply!(backend, ZZ(π * tApi), position...;
        ancilla=nQubits(geometry)+bond_index[(min(position...), max(position...))])
    end
    for position in eachcol(bonds(geometry; kitaevType=:X))
        apply!(backend, ZZ(π * tApi), position...;
        ancilla=nQubits(geometry)+bond_index[(min(position...), max(position...))])
    end
    for position in eachcol(bonds(geometry; kitaevType=:Y))
        apply!(backend, ZZ(π * tApi), position...;
        ancilla=nQubits(geometry)+bond_index[(min(position...), max(position...))])
    end
    for position in eachcol(qubits_)
        apply!(backend, Measure_Z(), position...)
    end
    return backend
end
