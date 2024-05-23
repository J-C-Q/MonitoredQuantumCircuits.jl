# using ITensors

function itensorTest()
    # Define the qubits (indices)
    qubits = [Index(2; tags="Qubit", plev=n) for n = 1:2]

    # Initialize the quantum state as |00⟩
    psi = productMPS(qubits)


    # H = hadamard(1)  # Hadamard gate on qubit 1
    psi = apply(itensor([1/sqrt(2) 1/sqrt(2); 1/sqrt(2) -1/sqrt(2)], Index(2), Index(2)), psi, qubits[1])

    # Apply the CNOT gate with qubit 1 as control and qubit 2 as target
    # CNOT = cnot(1, 2)  # CNOT gate from qubit 1 to 2
    # psi = apply(gate(CNOT, qubits[1], qubits[2]), psi)

    # # Measure the qubits in the computational basis
    # measurements = measure(psi, qubits; nshots=1024)

    # # Print the measurement outcomes
    # println("Measurement outcomes: ", measurements)


end
