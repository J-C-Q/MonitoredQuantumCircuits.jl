include("utils/cycles.jl")
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
