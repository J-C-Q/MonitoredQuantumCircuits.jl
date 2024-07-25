function RandomCircuit(lattice::HeavyChainLattice)
    operations = Operation[ZZ(), XX(), YY()]

    operationPositions = [(i, i + 1, i + 2) for i in 1:2:length(lattice)-2]
    operationPointers = [rand(1:length(operations)) for _ in 1:length(operationPositions)]
    executionOrder = collect(1:length(operationPositions))
    return Circuit(lattice, operations, operationPositions, operationPointers, executionOrder)
end
