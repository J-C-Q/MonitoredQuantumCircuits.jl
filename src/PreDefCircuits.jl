include("utils.jl")
function SQGO_randomCircuit(chip::IBMQChip, numberOfGates::Int)
    basisGates = chip.backend.gates

    gates = sample(basisGates, numberOfGates)
end

function nishimori_on_Eagler3_1D(token::String)
    chip = IBMQChip("brisbane", token)
    couplingMap = chip.backend.coupling_map.get_edges()
    nqubits = 14
    anxilaryquibits = 0:2:13
    circuit = QiskitQuantumCircuit(nqubits, nqubits)

    # add H on all qubits
    for i in 0:nqubits-1
        circuit.qc.h(i)
    end

    # add Rzz gates
    for i in 0:2:nqubits-1
        circuit.qc.rzz(π / 2, i, i + 1)
    end

    qiskitPrint(circuit)
end
