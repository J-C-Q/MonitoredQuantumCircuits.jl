include("utils/cycles.jl")
function NishimoriCircuit(lattice::HeavyChainLattice)
    operations = Operation[ZZ()]

    operationPositions = [(i, i + 1, i + 2) for i in collect(1:2:length(lattice)-2)]
    operationPointers = fill(1, length(operationPositions))
    executionOrder = fill(1, length(operationPositions))
    return Circuit(lattice, operations, operationPositions, operationPointers, executionOrder)
end

function NishimoriCircuit(lattice::HeavyHexagonLattice)
    cycles = mysimplecycles_limited_length(lattice.graph, 12, 10^6)
    # println(cycles)
    test = [(cycle[i], cycle[mod1(i + 1, length(cycle))], cycle[mod1(i + 2, length(cycle))], 1, mod1(i, 3)) for cycle in cycles for i in 1:2:length(cycle)]
    test = unique!(x -> Set(x[1:3]), test)
    # println(test)
    operations = Operation[ZZ()]
    operationPositions = [(i, j, k) for (i, j, k, _, _) in test]
    operationPointers = [ptr for (_, _, _, ptr, _) in test]
    executionOrder = [ord for (_, _, _, _, ord) in test]
    return Circuit(lattice, operations, operationPositions, operationPointers, executionOrder)
end

# function NishimoriCircuit(lattice::HeavySquareLattice)
#     cycles = mysimplecycles_limited_length(lattice.graph, 8, 10^6)
# end
