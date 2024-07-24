function NishimoriCircuit(lattice::HeavyChainLattice)
    operations = [ZZ()]

    operationPositions = collect(1:2:length(lattice)-2)
    operationPointers = fill(1, length(operationPositions))
    executionOrder = fill(1, length(operationPositions))
    return Circuit(lattice, operations, operationPositions, operationPointers, executionOrder)
end
