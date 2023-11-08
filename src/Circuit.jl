module QuantumCircuits

abstract type Quantum_Circuit

end

struct DAG_Circuit <: Quantum_Circuit
    edges::Array{Tuple{Int,Int},1} # Connenctions between gates as index pairs
    gateTypes::Array{Symbol,1}
    involdeQubits::Array{Array{Int,1},1} # Involved qubits for each gate in order
end

struct Gate
    gateType::Symbol
    involvedQubits::Array{Int,1}
end

function DAG_Circuit(Gates::Array{Gate,1})
    gateTypes = [gate.gateType for gate in Gates]
    involvedQubits = [gate.involvedQubits for gate in Gates]
    # The number of edges in the DGA in the case of no gates is equal to the number of qubits. Furthermore it increases by one for every time a qubit is involved in a gate.
    edges = Array{Tuple{Int,Int},1}(undef,length(Gates)+sum(length.(involvedQubits)))
    i = 1
    for qubits in involvedQubits

    end




end # module Circuit
