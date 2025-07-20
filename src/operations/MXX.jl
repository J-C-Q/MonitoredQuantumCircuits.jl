"""
    MXX() <: MeasurementOperation

The MXX operation is a two-qubit gate that applies an XX interaction between the two qubits. It is a type of measurement operation that can be used in quantum circuits.
"""
struct MXX <: MeasurementOperation
    function MXX()
        new()
    end
    function MXX(t::Float64)
        if t == π/4
            return new()
        end
        return WeakMXX(t)
    end
end

function nQubits(::MXX)
    return 2
end
function isClifford(::MXX)
    return true
end
function nAncilla(::MXX)
    return 1
end
