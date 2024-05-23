
"""
Construct you circuit with qiskit, then check if it is compatible with the geometry
"""
function checkCompatible(circuit::QiskitQuantumCircuit, geometry::SimpleGraph; mapping=x -> x + 1)
    isCompatible = true
    for operation in circuit.qc.data
        qubits = [qubit.index for qubit in operation[1]]
        if length(qubits) != 2
            continue
        end
        if !has_edge(geometry, mapping.(qubits)...)
            isCompatible = false
            break
        end
    end
    return isCompatible
end
