struct IBMQ_Falcon <: Geometry
    graph::Graph
    bonds::Vector{Bond}
    control_qubits::Vector{Int}
    system_qubits::Vector{Int}
    system_bonds::Vector{Bond}
    control_qubit_for_system_bond::Dict{Bond{Int64},Int64}
    function IBMQ_Falcon()
        adj = falses(27,27)
        adj[1, 2] = true
        adj[2, 1] = true

        adj[2, 5] = true
        adj[5, 2] = true

        adj[5, 8] = true
        adj[8, 5] = true

        adj[8, 7] = true
        adj[7, 8] = true

        adj[8, 11] = true
        adj[11, 8] = true

        adj[11, 13] = true
        adj[13, 11] = true

        adj[13, 16] = true
        adj[16, 13] = true

        adj[16, 19] = true
        adj[19, 16] = true

        adj[19, 22] = true
        adj[22, 19] = true

        adj[19, 18] = true
        adj[18, 19] = true

        adj[22, 24] = true
        adj[24, 22] = true

        adj[24, 25] = true
        adj[25, 24] = true

        adj[25, 26] = true
        adj[26, 25] = true

        adj[26, 27] = true
        adj[27, 26] = true

        adj[2, 3] = true
        adj[3, 2] = true

        adj[3, 4] = true
        adj[4, 3] = true

        adj[4, 6] = true
        adj[6, 4] = true

        adj[6, 9] = true
        adj[9, 6] = true

        adj[9, 10] = true
        adj[10, 9] = true

        adj[9, 12] = true
        adj[12, 9] = true

        adj[12, 15] = true
        adj[15, 12] = true

        adj[15, 14] = true
        adj[14, 15] = true

        adj[14, 13] = true
        adj[13, 14] = true

        adj[14, 17] = true
        adj[17, 14] = true

        adj[15, 17] = true
        adj[17, 15] = true

        adj[17, 20] = true
        adj[20, 17] = true

        adj[20, 21] = true
        adj[21, 20] = true

        adj[20, 23] = true
        adj[23, 20] = true

        adj[23, 26] = true
        adj[26, 23] = true

        system_qubits = [2,4,8,9,13,15,19,20,24,26]
        control_qubits = [1,3,5,6,7,10,11,12,14,16,17,18,21,22,23,25,27]

        system_bonds = Bond.([1, 1, 3, 5, 7, 9, 2, 4, 6, 8, 5],[2, 3, 5, 7, 9, 10, 4, 6, 8, 10, 6] )

        control_qubit_for_system_bond = Dict{Bond{Int64},Int64}(
            Bond(1, 2) => 2,
            Bond(1, 3) => 3,
            Bond(2, 4) => 4,
            Bond(4, 6) => 8,
            Bond(3, 5) => 7,
            Bond(5, 6) => 9,
            Bond(5, 7) => 10,
            Bond(7, 9) => 14,
            Bond(9, 10) => 16,
            Bond(6, 8) => 11,
            Bond(8, 10) => 15,
        )

        graph = SimpleGraph(adj)

        return new(graph,
        collectBonds(IBMQ_Falcon,graph),
        control_qubits,
        system_qubits,
        system_bonds,
        control_qubit_for_system_bond)
    end

end
function collectBonds(::Type{IBMQ_Falcon}, graph::Graph)
    bonds = Vector{Bond{Int64}}(undef, ne(graph))
    for (i,e) in enumerate(edges(graph))
        src, dst = Graphs.src(e), Graphs.dst(e)
        bonds[i] = Bond(src, dst)
    end
    return bonds
end

function bonds(geometry::IBMQ_Falcon)
    return geometry.system_bonds
end
function hardware_bonds(geometry::IBMQ_Falcon)
    return geometry.bonds
end
function system_qubits(geometry::IBMQ_Falcon)
    return geometry.system_qubits
end
function control_qubits(geometry::IBMQ_Falcon)
    return geometry.control_qubits
end
function nQubits(geometry::IBMQ_Falcon)
    return length(geometry.system_qubits)
end
function nBonds(geometry::IBMQ_Falcon)
    return length(geometry.system_bonds)
end
function nControlQubits(geometry::IBMQ_Falcon)
    return length(geometry.control_qubits)
end
function nHardwareQubits(geometry::IBMQ_Falcon)
    return nQubits(geometry) + nControlQubits(geometry)
end
function qubits(geometry::IBMQ_Falcon)
    return 1:length(geometry.system_qubits)
end

function get_control(geometry::IBMQ_Falcon, bond::Bond{Int64})
    return geometry.control_qubit_for_system_bond[bond]
end

export IBMQ_Falcon, hardware_bonds, bonds, system_qubits, control_qubits, nSystemQubits, nControlQubits, get_control
