function NishimorisCat(geometry::HoneycombGeometry{Open}; depth::Integer=100)
    circuit = Circuit(geometry)

    for position in 1:nQubits(geometry)
        apply!(circuit, H(), position)
    end

    for position in kitaevZ(geometry)
        apply!(circuit, Weak_ZZ(π / 4), position...)
    end
    for position in kitaevX(geometry)
        apply!(circuit, Weak_ZZ(π / 4), position...)
    end
    for position in kitaevY(geometry)
        apply!(circuit, Weak_ZZ(π / 4), position...)
    end
    for position in 1:nQubits(geometry)
        apply!(circuit, Measure_Z(), position)
    end



    return circuit
end
