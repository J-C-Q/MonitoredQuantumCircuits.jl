"""
    MZZ() <: MeasurementOperation

The MZZ operation is a two-qubit measurement operation that measures the state of two qubits in the ZZ basis. The first qubit is the target qubit, and the second qubit is an ancilla qubit that is used to store the result of the operation.
"""
struct MZZ <: MeasurementOperation
    function MZZ()
        new()
    end
    function MZZ(t::Float64)
        if t == π/4
            return new()
        end
        return WeakMZZ(t)
    end
end



function nQubits(::MZZ)
    return 2
end
function isClifford(::MZZ)
    return true
end
function nAncilla(::MZZ)
    return 1
end
