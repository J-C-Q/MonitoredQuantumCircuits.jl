"""
    ZZ() <: MeasurementOperation

The ZZ operation is a two-qubit measurement operation that measures the state of two qubits in the ZZ basis. The first qubit is the target qubit, and the second qubit is an ancilla qubit that is used to store the result of the operation.
"""
struct ZZ <: MeasurementOperation
    function ZZ()
        new()
    end
    function ZZ(t::Float64)
        if t == π/4
            return new()
        end
        return Weak_ZZ(t)
    end
end



function nQubits(::ZZ)
    return 2
end
function isClifford(::ZZ)
    return true
end
function nAncilla(::ZZ)
    return 1
end
