include("utils.jl")
function SQGO_randomCircuit(chip::IBMQChip, numberOfGates::Int)
    basisGates = chip.backend.gates

    gates = sample(basisGates, numberOfGates)
end

function nishimori_on_Eagler3_1D(token::String)
    chip = IBMQChip("ibm_brisbane", token)
    couplingMap = chip.backend.coupling_map.get_edges()
    nqubits = 13
    anxilaryquibits = 0:2:13
    circuit = QiskitQuantumCircuit(nqubits)

    # add H on all qubits
    for _ in 1:nqubits
        circuit.qc.h()
    end

    qiskitPrint(circuit)
end
