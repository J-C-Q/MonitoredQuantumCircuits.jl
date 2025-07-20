"""
    MYY() <: MeasurementOperation

The MYY operation is a two-qubit gate that applies a YY interaction between the two qubits. The operation is used to measure the state of the qubits in the YY basis.
"""
struct MYY <: MeasurementOperation
    function MYY()
        new()
    end
    function MYY(t::Float64)
        if t == π/4
            return new()
        end
        return WeakMYY(t)
    end
end

function nQubits(::MYY)
    return 2
end
function isClifford(::MYY)
    return true
end
function nAncilla(::MYY)
    return 1
end
