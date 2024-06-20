module ITensorsInterface
using ITensors

## building blocks for disordered Ising Tensor Network:
function bondInteractionMatrices(tA::Real; tB::Real=0.25π)

    # generate the two possible bond interaction matrices
    # that contributes to the Boltzmann weight
    # analogous to 1D ising quantum transfer matrix

    t = (tA + tB) / 2
    tau = (tA - tB) / 2

    bondMatrix1 = Matrix{Float64}([cos(2t)^2 cos(2tau)^2; cos(2tau)^2 cos(2t)^2] ./ sqrt(2))
    bondMatrix2 = Matrix{Float64}([sin(2t)^2 sin(2tau)^2; sin(2tau)^2 sin(2t)^2] ./ sqrt(2))
    bondMatrixList = (bondMatrix1, bondMatrix2)
    return bondMatrixList
end

struct IsingMPOset
    bulkMPOlist::Matrix{Vector{Union{ITensor,Index}}}
    leftMPOlist::Matrix{Vector{Union{ITensor,Index}}}
    rightMPOlist::Vector{Vector{Union{ITensor,Index}}}
    bulkMPSlist::Vector{Vector{Union{ITensor,Index}}}
    leftMPSlist::Vector{Vector{Union{ITensor,Index}}}
    rightMPS::Vector{Union{ITensor,Index}}
end

function isingMPOset(tA::Real; tB::Real=0.25π)

    # for binary disordered Ising model,
    # four possible unit-cell tensors in the bulk

    # get the bond interaction matrices to build up MPO
    bondMatrixList = bondInteractionMatrices(tA; tB)
    bondDimension = size(bondMatrixList[1], 1)
    s = Index(bondDimension)
    l = Index(bondDimension)
    r = Index(bondDimension)

    # bulk MPO
    bulkMPOlist = Matrix{Vector{Union{ITensor,Index}}}(undef, 2, 2)
    leftMPOlist = Matrix{Vector{Union{ITensor,Index}}}(undef, 2, 2)
    rightMPOlist = Vector{Vector{Union{ITensor,Index}}}(undef, 2)
    bulkMPSlist = Vector{Vector{Union{ITensor,Index}}}(undef, 2)
    leftMPSlist = Vector{Vector{Union{ITensor,Index}}}(undef, 2)

    possibleMeasurementOutcomes = (0, 1)

    for sy in possibleMeasurementOutcomes
        By = bondMatrixList[sy+1] # y bond matrix
        for sx in possibleMeasurementOutcomes
            Bx = bondMatrixList[sx+1] # x bond matrix

            # bulk MPO set
            T = delta(l, s', r', s'') * ITensor(Bx, r', r) * ITensor(By, s, s'')
            bulkMPOlist[sx+1, sy+1] = Union{ITensor,Index}[T, l, s', s, r]

            # left boundary MPO set
            T = delta(s', r', s'') * ITensor(Bx, r', r) * ITensor(By, s, s'')
            leftMPOlist[sx+1, sy+1] = Union{ITensor,Index}[T, s', s, r]

            if sy == 0
                # bulk MPS set
                T = delta(l, s, r') * ITensor(Bx, r', r)
                bulkMPSlist[sx+1] = Union{ITensor,Index}[T, l, s, r]

                # left MPS set
                T = delta(s, r') * ITensor(Bx, r', r)
                leftMPSlist[sx+1] = Union{ITensor,Index}[T, s, r]
            end
        end
        T = delta(l, s', s'') * ITensor(By, s, s'')
        rightMPOlist[sy+1] = Union{ITensor,Index}[T, l, s', s]
    end
    rightMPS = Union{ITensor,Index}[delta(l, s), l, s]
    return IsingMPOset(bulkMPOlist, leftMPOlist, rightMPOlist, bulkMPSlist, leftMPSlist, rightMPS)
end

function transferMPO(sites::Vector{<:Index})
end

end
