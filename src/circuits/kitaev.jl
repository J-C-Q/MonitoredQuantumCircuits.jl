# include("utils/cycles.jl")
function KitaevCircuit(lattice::HeavyHexagonLattice)
    cycles = mysimplecycles_limited_length(lattice.graph, 12, 10^6)

    test = [(cycle[i], cycle[mod1(i + 1, length(cycle))], cycle[mod1(i + 2, length(cycle))], mod1(i, 3), mod1(i, 3)) for cycle in cycles for i in 1:2:length(cycle)]
    test = unique!(x -> Set(x[1:3]), test)
    operations = Operation[ZZ(), XX(), YY()]
    operationPositions = [(i, j, k) for (i, j, k, _, _) in test]
    operationPointers = [ptr for (_, _, _, ptr, _) in test]
    executionOrder = [ord for (_, _, _, _, ord) in test]
    return Circuit(lattice, operations, operationPositions, operationPointers, executionOrder)
end

function KitaevCircuit(lattice::HexagonToricCodeLattice)
    lattice.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    lattice.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    [(neighbors(lattice.graph, i)..., i) for i in findfirst(x -> x == 1, lattice.isAncilla):nv(lattice.graph)]
    # cycles = mysimplecycles_limited_length(lattice.graph, 12, 10^6)


    # @info cycles
    # test = [(cycle[i], cycle[mod1(i + 1, length(cycle))], cycle[mod1(i + 2, length(cycle))], mod1(i, 3), mod1(i, 3)) for cycle in cycles for i in 1:2:length(cycle)]
    # test = unique!(x -> Set(x[1:3]), test)
    # operations = Operation[ZZ(), XX(), YY()]
    # operationPositions = [(i, j, k) for (i, j, k, _, _) in test]
    # operationPointers = [ptr for (_, _, _, ptr, _) in test]
    # executionOrder = [ord for (_, _, _, _, ord) in test]
    # return Circuit(lattice, operations, operationPositions, operationPointers, executionOrder)
end

function KitaevCircuit(lattice::HeavyHexagonLattice, layers::Integer)
    cycles = mysimplecycles_limited_length(lattice.graph, 12, 10^6)

    test = [(cycle[i], cycle[mod1(i + 1, length(cycle))], cycle[mod1(i + 2, length(cycle))], mod1(i, 3), mod1(i, 3)) for cycle in cycles for i in 1:2:length(cycle)]
    test = unique!(x -> Set(x[1:3]), test)
    operations = Operation[ZZ(), XX(), YY()]
    operationPositions = repeat(copy([(i, j, k) for (i, j, k, _, _) in test]), layers)
    operationPointers = repeat(copy([ptr for (_, _, _, ptr, _) in test]), layers)
    executionOrder = [ord + (i - 1) * 3 for i in 1:layers for (_, _, _, _, ord) in test]
    return Circuit(lattice, operations, operationPositions, operationPointers, executionOrder)
end

function KitaevCircuit(lattice::HeavyHexagonLattice, px::Float64, py::Float64, pz::Float64, depth::Integer)

    px + py + pz ≈ 1.0 || throw(ArgumentError("The sum of the probabilities must be 1.0"))

    cycles = mysimplecycles_limited_length(lattice.graph, 12, 10^6)

    test = [(cycle[i], cycle[mod1(i + 1, length(cycle))], cycle[mod1(i + 2, length(cycle))], mod1(i, 3), mod1(i, 3)) for cycle in cycles for i in 1:2:length(cycle)]
    test = unique!(x -> Set(x[1:3]), test)
    possibleXX = [(i, j, k, ptr, ord) for (i, j, k, ptr, ord) in test if ptr == 2]
    possibleYY = [(i, j, k, ptr, ord) for (i, j, k, ptr, ord) in test if ptr == 3]
    possibleZZ = [(i, j, k, ptr, ord) for (i, j, k, ptr, ord) in test if ptr == 1]
    possibleMatrix = [possibleZZ, possibleXX, possibleYY]
    operations = Operation[ZZ(), XX(), YY()]
    picks = Vector{Int64}(undef, depth)
    for i in 1:depth
        p = rand()
        if p < pz
            picks[i] = 1
        elseif p < pz + px
            picks[i] = 2
        else
            picks[i] = 3
        end
    end
    operationPositions = [rand(possibleMatrix[picks[i]])[1:3] for i in 1:depth]
    operationPointers = picks
    executionOrder = collect(1:length(picks))
    return Circuit(lattice, operations, operationPositions, operationPointers, executionOrder)

end


function KitaevCircuit(lattice::HexagonToricCodeLattice, px::Float64, py::Float64, pz::Float64, depth::Integer)
    px + py + pz ≈ 1.0 || throw(ArgumentError("The sum of the probabilities must be 1.0"))

    cycles = mysimplecycles_limited_length(lattice.graph, 12, 10^6)

    test = [(cycle[i], cycle[mod1(i + 1, length(cycle))], cycle[mod1(i + 2, length(cycle))], mod1(i, 3), mod1(i, 3)) for cycle in cycles for i in 1:2:length(cycle)]
    test = unique!(x -> Set(x[1:3]), test)
    possibleXX = [(i, j, k, ptr, ord) for (i, j, k, ptr, ord) in test if ptr == 2]
    possibleYY = [(i, j, k, ptr, ord) for (i, j, k, ptr, ord) in test if ptr == 3]
    possibleZZ = [(i, j, k, ptr, ord) for (i, j, k, ptr, ord) in test if ptr == 1]
    possibleMatrix = [possibleZZ, possibleXX, possibleYY]
    operations = Operation[ZZ(), XX(), YY()]
    picks = Vector{Int64}(undef, depth)
    for i in 1:depth
        p = rand()
        if p < pz
            picks[i] = 1
        elseif p < pz + px
            picks[i] = 2
        else
            picks[i] = 3
        end
    end
    operationPositions = [rand(possibleMatrix[picks[i]])[1:3] for i in 1:depth]
    operationPointers = picks
    executionOrder = collect(1:length(picks))
    return Circuit(lattice, operations, operationPositions, operationPointers, executionOrder)
end
