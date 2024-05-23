using ITensors

N = 2  # Number of qubits
sites = siteinds(2, N)  # Create qubit indices

# Initialize state |00>
psi = MPS(sites)

# Hadamard gate for qubit 1
H = ITensor([1.0/sqrt(2) 1.0/sqrt(2); 1.0/sqrt(2) -1.0/sqrt(2)], sites[1], prime(sites[1]))

newA = H * psi[1]
newA = noprime(newA)
psi[1] = newA
# Apply the Hadamard gate to the first qubit

@show psi

function apply_singlequbit_gate!(psi, gate, qubit)
    newA = gate * psi[qubit]
    newA = noprime(newA)
    psi[qubit] = newA
end
