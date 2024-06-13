module quantumCircuit



struct QuantumGate{N}
    qubits::Vector{Int}
    function QuantumGate(qubits::AbstractVector{Int})

        return new{length(qubits)}(qubits)

    end
end



end
