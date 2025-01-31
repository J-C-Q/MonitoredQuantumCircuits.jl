# include("utils/cycles.jl")

function KekuleCircuit(lattice::HeavyHexagonLattice)
    cycles = mysimplecycles_limited_length(lattice.graph, 12, 10^6)
    sort!(cycles, by=(x -> x[1]))
    test = [(cycle[i], cycle[mod1(i + 1, length(cycle))], cycle[mod1(i + 2, length(cycle))], mod1((2 * mod1(k, 2) + mod1(j, 3)), 3), mod1((2 * mod1(k, 2) + mod1(j, 3)), 3)) for (j, cycle) in enumerate(cycles) for (k, i) in enumerate(1:2:length(cycle))]
    test = unique!(x -> Set(x[1:3]), test)
    # println(test)
    operations = Operation[ZZ(), XX(), YY()]
    operationPositions = [(i, j, k) for (i, j, k, _, _) in test]
    operationPointers = [ptr for (_, _, _, ptr, _) in test]
    executionOrder = [ord for (_, _, _, _, ord) in test]
    return FiniteDepthCircuit(lattice, operations, operationPositions, operationPointers, executionOrder)
end

function KekuleCircuit(lattice::HexagonToricCodeLattice)
    lattice.sizeX % 6 == 0 || throw(ArgumentError("The sizeX must be a multiple of 6"))
    lattice.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    positions = [(neighbors(lattice.graph, i)[1], i, neighbors(lattice.graph, i)[2]) for i in nQubits(lattice)+1:nv(lattice.graph)]
    operations = Operation[ZZ(), XX(), YY()]
    operationPointers = vcat([1, 2, 3], repeat([2, 3, 1, 3], div(lattice.sizeX - 2, 2)), [3],
        repeat(vcat([2, 1], repeat([1, 3, 2], div(lattice.sizeX - 2, 2)), [3],
                [1, 2, 3], repeat([2, 1, 3], div(lattice.sizeX - 2, 2))), div(lattice.sizeY - 2, 2)),
        [2, 1], repeat([1, 2], div(lattice.sizeX - 2, 2)))

    operationPointers = vcat(
        [1, 3, 2, 2, 3, 3, 1, 1, 2, 2, 3, 3, 1], repeat([1, 2, 2, 3, 3, 1, 1, 2, 2, 3, 3, 1], div(lattice.sizeX, 6) - 2), [3, 2, 2, 3, 3, 1, 1, 2, 2, 3, 1],
        repeat(vcat(
                [1, 3, 2, 3, 3, 1, 2, 2, 3, 1], # 4
                repeat([1, 2, 3, 3, 1, 2, 2, 3, 1], div(lattice.sizeX, 6) - 2),
                [1, 2, 3, 3, 1, 2, 2, 1],
                [1, 3, 2, 2, 3, 1, 1, 2, 3, 3], # 3
                repeat([1, 2, 2, 3, 1, 1, 2, 3, 3], div(lattice.sizeX, 6) - 2), [1, 2, 2, 3, 1, 1, 2, 3],
            ), div(lattice.sizeY, 2) - 1),
        [1, 3, 2, 3, 1, 2, 3], repeat([1, 2, 3, 1, 2, 3], div(lattice.sizeX, 6) - 2), [1, 2, 3, 1, 2])
    executionOrder = operationPointers
    return FiniteDepthCircuit(lattice, operations, positions, operationPointers, executionOrder)
end


function KekuleCircuit(lattice::HeavyHexagonLattice, layers::Integer)
    cycles = mysimplecycles_limited_length(lattice.graph, 12, 10^6)
    a = [1, 2, 3]
    test = [(cycle[i], cycle[mod1(i + 1, length(cycle))], cycle[mod1(i + 2, length(cycle))], mod1((2 * mod1(k, 2) + mod1(j, 3)), 3), mod1((2 * mod1(k, 2) + mod1(j, 3)), 3)) for (j, cycle) in enumerate(cycles) for (k, i) in enumerate(1:2:length(cycle))]
    test = unique!(x -> Set(x[1:3]), test)
    # println(test)
    operations = Operation[ZZ(), XX(), YY()]
    operationPositions = repeat(copy([(i, j, k) for (i, j, k, _, _) in test]), layers)
    operationPointers = repeat(copy([ptr for (_, _, _, ptr, _) in test]), layers)
    executionOrder = [ord + (i - 1) * 3 for i in 1:layers for (_, _, _, _, ord) in test]
    return FiniteDepthCircuit(lattice, operations, operationPositions, operationPointers, executionOrder)
end

function KekuleCircuit(lattice::HexagonToricCodeLattice, px::Float64, py::Float64, pz::Float64, depth::Integer)
    px + py + pz ≈ 1.0 || throw(ArgumentError("The sum of the probabilities must be 1.0"))

    # lattice.sizeX % 6 == 0 || throw(ArgumentError("The sizeX must be a multiple of 6"))
    # lattice.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    # positions = [(neighbors(lattice.graph, i)[1], i, neighbors(lattice.graph, i)[2]) for i in nQubits(lattice)+1:nv(lattice.graph)]
    operations = Operation[ZZ(), XX(), YY()]
    # pointers = vcat(
    #     [1, 3, 2, 2, 3, 3, 1, 1, 2, 2, 3, 3, 1], repeat([1, 2, 2, 3, 3, 1, 1, 2, 2, 3, 3, 1], div(lattice.sizeX, 6) - 2), [3, 2, 2, 3, 3, 1, 1, 2, 2, 3, 1],
    #     repeat(vcat(
    #             [1, 3, 2, 3, 3, 1, 2, 2, 3, 1], # 4
    #             repeat([1, 2, 3, 3, 1, 2, 2, 3, 1], div(lattice.sizeX, 6) - 2),
    #             [1, 2, 3, 3, 1, 2, 2, 1],
    #             [1, 3, 2, 2, 3, 1, 1, 2, 3, 3], # 3
    #             repeat([1, 2, 2, 3, 1, 1, 2, 3, 3], div(lattice.sizeX, 6) - 2), [1, 2, 2, 3, 1, 1, 2, 3],
    #         ), div(lattice.sizeY, 2) - 1),
    #     [1, 3, 2, 3, 1, 2, 3], repeat([1, 2, 3, 1, 2, 3], div(lattice.sizeX, 6) - 2), [1, 2, 3, 1, 2])


    # possibleXX = [p for (i, p) in enumerate(positions) if pointers[i] == 2]
    # possibleYY = [p for (i, p) in enumerate(positions) if pointers[i] == 3]
    # possibleZZ = [p for (i, p) in enumerate(positions) if pointers[i] == 1]
    possibleZZ, possibleXX, possibleYY = kekuleBonds(lattice)
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
    operationPositions = [rand(possibleMatrix[picks[i]]) for i in 1:depth]
    operationPointers = picks
    executionOrder = collect(1:depth)
    return FiniteDepthCircuit(lattice, operations, operationPositions, operationPointers, executionOrder)
end
