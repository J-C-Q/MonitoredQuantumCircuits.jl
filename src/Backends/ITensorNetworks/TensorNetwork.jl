struct ITensorCircuit
    network::ITensorNetwork
    gates::Vector{ITensor}
end

function translate(::Type{ITensorCircuit}, circuit::Circuit)
    s = siteinds("S=1/2", circuit.lattice.graph)
    tn = ITensorNetwork(s; link_space=2)
    tc = ITensorCircuit(tn, ITensor[])
    # iterate execution steps
    # for i in unique(circuit.executionOrder)
    #     # get all operations in the step
    #     operationsInStep = _getOperations(circuit, i)
    #     # get depth of the deepest operation in the step
    #     maximumDepth = maximum([depth(circuit.operations[circuit.operationPointers[j]]) for j in operationsInStep])
    #     # iterate depth of the operations
    #     for k in 1:maximumDepth
    #         # iterate operations in the step
    #         for j in operationsInStep
    #             ptr = circuit.operationPointers[j]
    #             # only apply the k-th instruction of the operation, if deep enough
    #             if k <= depth(circuit.operations[ptr])
    #                 apply!(tn, circuit.operations[ptr], k, circuit.operationPositions[j]...)
    #             end
    #         end
    #     end
    # end
    # qc.measure_all()
    return tc
end
