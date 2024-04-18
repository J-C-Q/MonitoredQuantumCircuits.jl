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
    # transpiled = qiskitTranspile(circuit, chip)
    # circuit = QiskitQuantumCircuit(transpiled)
    # qiskitPrint(circuit)
    return circuit
end
