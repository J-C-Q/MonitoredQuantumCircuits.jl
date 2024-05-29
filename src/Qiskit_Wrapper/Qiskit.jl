"""
A wrapper for the qiskit QuantumCircuit python class.
"""
const QuantumCircuitPropertieTypes::Dict{Symbol,Type} = Dict(
    :name => String,
    :global_phase => Float64,
    :metadata => Dict,
    :ancillas => Vector,
    :qubits => Vector{Qubit},)

struct QuantumCircuit
    qiskit_quantumcirucit::Py
    name::Nothing
    global_phase::Nothing
    metadata::Nothing
    ancillas::Nothing
    qubits::Nothing



    function QuantumCircuit(qc::QuantumCircuit)
        return new(qc.qiskit_quantumcirucit)
    end
    function QuantumCircuit(qubits::Int)
        return new(qiskit.QuantumCircuit(qubits))
    end
    function QuantumCircuit(qubits::Int, cbits::Int)
        return new(qiskit.QuantumCircuit(qubits, cbits))
    end
    # function QiskitQuantumCircuit(qasm2code::String)
    #     return new(qasm2.loads(qasm2code))
    # end
end

Base.show(io::IO, ::MIME"text/plain", obj::QuantumCircuit) = print(io, obj.qiskit_quantumcirucit)
function Base.getproperty(qc::QuantumCircuit, prop::Symbol)
    if prop == :qiskit_quantumcirucit
        return getfield(qc, prop)
    else
        try
            return pyconvert(QuantumCircuitPropertieTypes[prop], getproperty(qc.qiskit_quantumcirucit, prop))
        catch
            return getproperty(qc.qiskit_quantumcirucit, prop)
        end
    end
end

function Base.setproperty!(qc::QuantumCircuit, prop::Symbol, value)
    if prop == :qiskit_quantumcirucit
        return setfield!(qc, prop, value)
    else
        # type check for the julia side interface
        if QuantumCircuitPropertieTypes[prop] == typeof(value)
            return setproperty!(qc.qiskit_quantumcirucit, prop, value)
        else
            throw(ArgumentError("The property $prop must be of type $(QuantumCircuitPropertieTypes[prop])"))
        end
    end
end
