function NishimorisCatClifford(geometry::HoneycombGeometry{Open})
    circuit = Circuit(geometry)

    for position in 1:nQubits(geometry)
        apply!(circuit, H(), position)
    end
    for position in eachcol(bonds(geometry; kitaevType=:Z))
        apply!(circuit, ZZ(), position...)
    end
    for position in eachcol(bonds(geometry; kitaevType=:X))
        apply!(circuit, ZZ(), position...)
    end
    for position in eachcol(bonds(geometry; kitaevType=:Y))
        apply!(circuit, ZZ(), position...)
    end
    for position in 1:nQubits(geometry)
        apply!(circuit, Measure_Z(), position)
    end



    return circuit
end
