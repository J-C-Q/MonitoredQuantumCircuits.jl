"""
A wrapper for the qiskit QuantumCircuit python class.
"""
const QuantumCircuitPropertieTypes::Dict{Symbol,Symbol} = Dict(
    :qc => Symbol("Py"),
    :name => Symbol("String"),
    :global_phase => Symbol("Float64"),
    :metadata => Symbol("Dict"),
    :ancillas => Symbol("Vector{Int64}"),)

struct QuantumCircuit
    qiskit_quantumcirucit::Py
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
            return pyconvert(eval(QuantumCircuitPropertieTypes[prop]), getproperty(qc.qiskit_quantumcirucit, prop))
        catch
            return getproperty(qc.qiskit_quantumcirucit, prop)
        end
    end
end

function Base.setproperty!(qc::QuantumCircuit, prop::Symbol, value)
    if prop == :qiskit_quantumcirucit
        return setfield!(qc, prop, value)
    else
        try
            return setproperty!(qc.qiskit_quantumcirucit, prop, value)
        catch
            throw(ArgumentError("The  property .$prop is of type $(eval(QuantumCircuitPropertieTypes[prop])) but $(typeof(value)) was provided."))
        end
    end
end
