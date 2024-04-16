include("utils.jl")
function SQGO_randomCircuit(chip::IBMQChip, numberOfGates::Int)
    basisGates = chip.backend.gates

    gates = sample(basisGates, numberOfGates)
end

function nishimori_on_Eagler3_1D(token::String)
    chip = IBMQChip("brisbane", token)
    couplingMap = chip.backend.coupling_map.get_edges()
    nqubits = 13
    anxilaryquibits = 1:2:nqubits-1
    circuit = QiskitQuantumCircuit(nqubits, nqubits)

    # add H on all qubits
    for i in 0:nqubits-1
        circuit.qc.h(i)
    end

    # add Rzz gates
    # blue
    for i in 0:2:nqubits-2
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    # red
    for i in 3:4:nqubits-2
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    # gray
    for i in 1:4:nqubits-2
        circuit.qc.rzz(π / 2, i, i + 1)
    end

    # h on all acillas
    for i in anxilaryquibits
        circuit.qc.h(i)
    end

    # measure acillas
    for i in anxilaryquibits
        circuit.qc.measure(i, i)
    end

    # measure A qubits
    for i in 0:4:nqubits-1
        circuit.qc.measure(i, i)
    end
    # transpiled = qiskitTranspile(circuit, chip)
    # circuit = QiskitQuantumCircuit(transpiled)
    # qiskitPrint(circuit)
    return circuit
end
