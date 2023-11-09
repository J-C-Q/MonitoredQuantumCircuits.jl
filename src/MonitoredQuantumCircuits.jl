module MonitoredQuantumCircuits

# Write your package code here.

"""
    DAG_Circuit(Gates::Array{Gate,1})

Constructs a directed acyclic graph (DAG) from a list of gates. The DAG is represented
by a list of edges, where each edge is a tuple of two integers. The integers represent
the index of the gate that is the source of the edge and the index of the gate that is
the target of the edge. The edges are ordered in the same way as the gates in the list
of gates. The first edge is the edge that is the source of the first gate and the last
edge is the edge that is the target of the last gate. The number of edges in the DAG
is equal to the number of gates plus the number of qubits involved in the gates.
Tested: No
"""
function DAG_Circuit(Gates::Array{Gate,1})
    gateTypes = [gate.gateType for gate in Gates]
    involvedQubits = [gate.involvedQubits for gate in Gates]
    # The number of edges in the DGA in the case of no gates is equal to the number of
    # qubits. Furthermore it increases by one for every time a qubit is involved in a gate.
    edges = Array{Tuple{Int,Int},1}(undef, length(Gates) + sum(length.(involvedQubits)))
    i = 1
    for qubits in involvedQubits

    end

    return nothing
end
end
