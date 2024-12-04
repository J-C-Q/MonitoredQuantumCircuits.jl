include("utils/cycles.jl")
function prep_kitaev(lattice::HexagonToricCodeLattice)
    # Measure all plaquettes, two long-cycles and all z-bonds
    allZZ, allXX, allYY = kitaevBonds(lattice)

    bond_to_type = Dict{Tuple{Int,Int,Int},Int}()
    for (i, j, k) in allZZ
        bond_to_type[(i, j, k)] = 1
    end
    for (i, j, k) in allXX
        bond_to_type[(i, j, k)] = 2
    end
    for (i, j, k) in allYY
        bond_to_type[(i, j, k)] = 3
    end

    all_plaquettes = mysimplecycles_limited_length(lattice.graph, 12, 10^6)
    for plaquette in all_plaquettes

    end

end
