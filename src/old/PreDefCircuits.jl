include("utils.jl")
function randomCircuit(chip::IBMQChip, numberOfGates::Int)
    qiskitcircuit = pyimport("qiskit.circuit")
    nqubits = chip.backend.num_qubits
    couplingMap = chip.backend.coupling_map.get_edges()
    supportedGates = chip.backend.gates[1:end-1]
    println(supportedGates)
    circuit = QiskitQuantumCircuit(nqubits, nqubits)
    for i in 1:numberOfGates
        gate = rand(supportedGates)
        if gate.parameters != 0
            instruction = qiskitcircuit.Instruction(gate.name, length(gate.coupling_map[1]), 0, [0])
        else
            instruction = qiskitcircuit.Instruction(gate.name, length(gate.coupling_map[1]), 0, [])
        end
        qubits = rand(gate.coupling_map)
        circuit.qc.append(instruction, qubits)
        # if gate.num_qubits == 1
        #     qubit = rand(0:nqubits-1)
        #     circuit.qc.append(gate, [qubit])
        # elseif gate.num_qubits == 2
        #     qubits = rand(couplingMap)
        #     circuit.qc.append(gate, qubits)
        # end
    end
    return circuit
end

function nishimori_on_Eagler3_1D(chip::IBMQChip)
    # fakeProvidor = pyimport("qiskit_ibm_runtime.fake_povider")
    # chip = IBMQChip("brisbane", token)
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
    # for i in 0:4:nqubits-1
    #     circuit.qc.measure(i, i)
    # end
    transpiled = qiskitTranspile(circuit, chip)
    circuit = QiskitQuantumCircuit(transpiled)
    # qiskitPrint(circuit)
    return circuit
end

function nishimori_on_Eagler3(chip::IBMQChip)
    # fakeProvidor = pyimport("qiskit_ibm_runtime.fake_povider")
    # chip = IBMQChip("brisbane", token)
    couplingMap = chip.backend.coupling_map.get_edges()
    nqubits = 127
    ancillaQubits = vcat(
        collect(1:2:11),
        collect(14:17),
        collect(19:2:32),
        collect(33:36),
        collect(38:2:51),
        collect(52:55),
        collect(57:2:70),
        collect(71:74),
        collect(76:2:89),
        collect(90:93),
        collect(95:2:108),
        collect(109:112),
        collect(115:2:126))
    circuit = QiskitQuantumCircuit(nqubits, nqubits)

    # add H on all qubits
    for i in 0:nqubits-1
        i != 13 && i != 113 && circuit.qc.h(i)
    end

    # add Rzz gates
    # blue
    for i in 0:2:11
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 18:2:31
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 37:2:50
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 56:2:69
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 75:2:88
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 94:2:107
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 114:2:125
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    # red
    for i in 3:4:11
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 19:4:31
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 40:4:50
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 57:4:69
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 78:4:88
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 95:4:107
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 115:4:126
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    circuit.qc.rzz(π / 2, 14, 18)
    circuit.qc.rzz(π / 2, 15, 22)
    circuit.qc.rzz(π / 2, 16, 26)
    circuit.qc.rzz(π / 2, 17, 30)
    circuit.qc.rzz(π / 2, 33, 39)
    circuit.qc.rzz(π / 2, 34, 43)
    circuit.qc.rzz(π / 2, 35, 47)
    circuit.qc.rzz(π / 2, 36, 51)
    circuit.qc.rzz(π / 2, 52, 56)
    circuit.qc.rzz(π / 2, 53, 60)
    circuit.qc.rzz(π / 2, 54, 64)
    circuit.qc.rzz(π / 2, 55, 68)
    circuit.qc.rzz(π / 2, 71, 77)
    circuit.qc.rzz(π / 2, 72, 81)
    circuit.qc.rzz(π / 2, 73, 85)
    circuit.qc.rzz(π / 2, 74, 89)
    circuit.qc.rzz(π / 2, 90, 94)
    circuit.qc.rzz(π / 2, 91, 98)
    circuit.qc.rzz(π / 2, 92, 102)
    circuit.qc.rzz(π / 2, 93, 106)
    circuit.qc.rzz(π / 2, 109, 114)
    circuit.qc.rzz(π / 2, 110, 118)
    circuit.qc.rzz(π / 2, 111, 122)
    circuit.qc.rzz(π / 2, 112, 126)

    # gray
    for i in 1:4:11
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 21:4:32
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 38:4:50
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 59:4:69
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 76:4:88
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 97:4:107
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    for i in 117:4:125
        circuit.qc.rzz(π / 2, i, i + 1)
    end
    circuit.qc.rzz(π / 2, 0, 14)
    circuit.qc.rzz(π / 2, 4, 15)
    circuit.qc.rzz(π / 2, 8, 16)
    circuit.qc.rzz(π / 2, 12, 17)
    circuit.qc.rzz(π / 2, 20, 33)
    circuit.qc.rzz(π / 2, 24, 34)
    circuit.qc.rzz(π / 2, 28, 35)
    circuit.qc.rzz(π / 2, 32, 36)
    circuit.qc.rzz(π / 2, 37, 52)
    circuit.qc.rzz(π / 2, 41, 53)
    circuit.qc.rzz(π / 2, 45, 54)
    circuit.qc.rzz(π / 2, 49, 55)
    circuit.qc.rzz(π / 2, 58, 71)
    circuit.qc.rzz(π / 2, 62, 72)
    circuit.qc.rzz(π / 2, 66, 73)
    circuit.qc.rzz(π / 2, 70, 74)
    circuit.qc.rzz(π / 2, 75, 90)
    circuit.qc.rzz(π / 2, 79, 91)
    circuit.qc.rzz(π / 2, 83, 92)
    circuit.qc.rzz(π / 2, 87, 93)
    circuit.qc.rzz(π / 2, 96, 109)
    circuit.qc.rzz(π / 2, 100, 110)
    circuit.qc.rzz(π / 2, 104, 111)
    circuit.qc.rzz(π / 2, 108, 112)


    # # h on all acillas
    for i in ancillaQubits
        circuit.qc.h(i)
    end

    # # measure acillas
    for i in ancillaQubits
        circuit.qc.measure(i, i)
    end
    circuit.qc.barrier()
    # measure A qubits
    j = 0
    for i in 0:nqubits-1
        if i in ancillaQubits || i == 13 || i == 113
            continue
        end
        j += 1
        if j % 2 == 0
            continue
        end
        circuit.qc.measure(i, i)
    end
    # transpiled = qiskitTranspile(circuit, chip)
    # circuit = QiskitQuantumCircuit(transpiled)
    # qiskitPrint(circuit)
    return circuit
end
