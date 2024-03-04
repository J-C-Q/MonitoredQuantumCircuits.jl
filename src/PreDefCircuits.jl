include("utils.jl")
function randomCircuit(chip::IBMQChip, numberOfGates::Int)
    basisGates = chip.backend.gates
    couplingMap = chip.backend.coupling_map

    gates = sample(basisGates, numberOfGates)
end

function nishimori(chip::IBMQChip)
    couplingMap = chip.backend.coupling_map.get_edges()
    edges = [NTuple{2,Int64}(get(couplingMap, i)) .+ (1, 1) for i in 0:length(couplingMap)-1]
    uniqueEdgeColoring(chip.backend.n_qubits, edges)
    # circuit = QiskitQuantumCircuit(chip.backend.n_qubits)



end
