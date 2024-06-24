module ITensorsInterface
include("../utils/iterator.jl")
using ITensors

## building blocks for disordered Ising Tensor Network:
function bondInteractionMatrices(tA::Real; tB::Real=0.25π)

    # generate the two possible bond interaction matrices
    # that contributes to the Boltzmann weight
    # analogous to 1D ising quantum transfer matrix

    t = (tA + tB) / 2
    tau = (tA - tB) / 2

    bondMatrix1 = Float64[cos(2t)^2 cos(2tau)^2; cos(2tau)^2 cos(2t)^2] ./ sqrt(2)
    bondMatrix2 = Float64[sin(2t)^2 sin(2tau)^2; sin(2tau)^2 sin(2t)^2] ./ sqrt(2)
    bondMatrixList = (bondMatrix1, bondMatrix2)
    return bondMatrixList
end

# struct MPOlist{N,M}
#     tensorList::Array{iTensor,N}
#     indexList::Array{Index,N + 1}
# end
# function MPOlist(size::Integer...; nIndices::Integer=3)
#     dim = length(size)
#     return new{dim,nIndices}(Array{ITensor}(undef, size), Array{Index}(undef, (size..., nIndices)))
# end

# struct MPSlist{N}
#     tensorList::Vector{iTensor}
#     indexList::Matrix{Index}
# end
# function MPOlist(size::Integer...)
#     dim = length(size)
#     return new{dim}(Array{ITensor}(undef, size), Array{Index}(undef, (size..., 3)))
# end

struct IsingMPOset{N<:Real,M<:Real}
    tA::N
    tB::M
    bulkMPOlist::Matrix{ITensor}
    leftMPOlist::Matrix{ITensor}
    rightMPOlist::Vector{ITensor}
    bulkMPSlist::Vector{ITensor}
    leftMPSlist::Vector{ITensor}
    rightMPS::ITensor
end
Base.show(io::IO, isingMPOset::IsingMPOset) = print(io, "IsingMPOset: tA=$(isingMPOset.tA), tB=$(isingMPOset.tB)")


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
    bulkMPOlist = Matrix{ITensor}(undef, 2, 2)
    leftMPOlist = Matrix{ITensor}(undef, 2, 2)
    rightMPOlist = Vector{ITensor}(undef, 2)
    bulkMPSlist = Vector{ITensor}(undef, 2)
    leftMPSlist = Vector{ITensor}(undef, 2)

    possibleMeasurementOutcomes = (0, 1)

    begin # sy = 0
        By = bondMatrixList[1] # y bond matrix
        for sx in possibleMeasurementOutcomes
            Bx = bondMatrixList[sx+1] # x bond matrix

            # bulk MPO set
            T = delta(l, s', r', s'') * ITensor(Bx, r', r) * ITensor(By, s, s'')
            bulkMPOlist[sx+1, 1] = T

            # left boundary MPO set
            T = delta(s', r', s'') * ITensor(Bx, r', r) * ITensor(By, s, s'')
            leftMPOlist[sx+1, 1] = T

            # bulk MPS set
            T = delta(l, s, r') * ITensor(Bx, r', r)
            bulkMPSlist[sx+1] = T

            # left MPS set
            T = delta(s, r') * ITensor(Bx, r', r)
            leftMPSlist[sx+1] = T

        end
        T = delta(l, s', s'') * ITensor(By, s, s'')
        rightMPOlist[1] = T
    end
    begin # sy = 1
        By = bondMatrixList[2] # y bond matrix
        for sx in possibleMeasurementOutcomes
            Bx = bondMatrixList[sx+1] # x bond matrix

            # bulk MPO set
            T = delta(l, s', r', s'') * ITensor(Bx, r', r) * ITensor(By, s, s'')
            bulkMPOlist[sx+1, 2] = T

            # left boundary MPO set
            T = delta(s', r', s'') * ITensor(Bx, r', r) * ITensor(By, s, s'')
            leftMPOlist[sx+1, 2] = T

        end
        T = delta(l, s', s'') * ITensor(By, s, s'')
        rightMPOlist[2] = T
    end
    rightMPS = delta(l, s)
    return IsingMPOset(tA, tB, bulkMPOlist, leftMPOlist, rightMPOlist, bulkMPSlist, leftMPSlist, rightMPS)
end

function transferMPO(
    sites::Vector{Index},
    sxList::Vector{T},
    syList::Vector{T},
    bulkMPOlist::Matrix{ITensor},
    leftMPOlist::Matrix{ITensor},
    rightMPOlist::Vector{ITensor}) where {T<:Integer}

    linkVector = [Index(2, "link,l=$i") for i in eachindex(sites)[1:end-1]]

    mpoVector = Vector{iTensor}(undef, length(sites))

    mpoVector[1] = ITensor(leftMPOlist[sxList[1]+1, syList[1]+1], sites[1]', sites[1], linkVector[1])
    mpoVector[end] = ITensor(rightMPOlist[syList[end]+1], linkVector[end-1], sites[end]', sites[end])
    for (siteIndex, site) in enumerate(sites, 2:length(sites)-1)
        mpoVector[siteIndex] = ITensor(bulkMPOlist[sxList[siteIndex]+1, syList[siteIndex]+1], linkVector[siteIndex-1], site', site, linkVector[siteIndex])
    end
    return MPO(mpoVector)
end

function boundaryMPS(
    sites::Vector{Index},
    sxList::Vector{T},
    bulkMPSlist::Vector{ITensor},
    leftMPSlist::Vector{ITensor},
    rightMPS::ITensor) where {T<:Integer}

    linkVector = [Index(2, "link,l=$i") for i in eachindex(sites)[1:end-1]]

    mpsVector = Vector{iTensor}(undef, length(sites))

    mpsVector[1] = ITensor(leftMPSlist[sxList[1]+1], sites[1], linkVector[1])
    mpsVector[end] = ITensor(rightMPS, linkVector[end-1], sites[end])
    for (siteIndex, site) in enumerate(sites, 2:length(sites)-1)
        mpsVector[siteIndex] = ITensor(bulkMPSlist[sxList[siteIndex]+1], linkVector[siteIndex-1], site, linkVector[siteIndex])
    end

    psi = MPS(mpsVector)
    normalize!(psi)
    return psi
end

function observableMPO(
    tA::Real,
    siteIndex::Integer,
    sites::Vector{Index},
    syList::Vector{T};
    tB::Real=0.25π) where {T<:Integer}

    bondMatrixList = bondInteractionMatrices(tA; tB)

    mpoVector = Vector{iTensor}(undef, length(sites))
    for (siteInd, site) in enumerate(sites)
        mpoVector[siteInd] = ITensor(bondMatrixList[syList[siteInd]+1], site', site)
    end
    wMPO = MPO(mpoVector)
    mpoVectorCopy = deepcopy(mpoVector)
    mpoVectorCopy[siteIndex] = ITensor(bondMatrixList[syList[siteIndex]+1] * Float64[1 0; 0 -1], sites[siteIndex]', sites[siteIndex])
    magnetizationMPO = MPO(mpoVectorCopy)
    mpoVectorCopy2 = deepcopy(mpoVector)
    mpoVectorCopy2[siteIndex] = ITensor(bondMatrixList[2-syList[sideIndex]], sites[siteIndex]', sites[siteIndex])
    wpMPO = MPO(mpoVectorCopy2)
    return wMPO, magnetizationMPO, wpMPO
end

function applyTransferMPOs(
    psi::MPS,
    sxGrid::Matrix{T},
    syGrid::Matrix{T},
    bulkMPOlist::Matrix{ITensor},
    leftMPOlist::Matrix{ITensor},
    rightMPOlist::Vector{ITensor};
    contractMethode::String="densitymatrix",
    cutoff::Real=0,
    maxDim::Real=0) where {T<:Integer}

    depth, Lx = size(sxGrid)
    sites = siteinds(psi)

    for d in 1:depth
        sxList = sxGrid[d, :]
        syList = syGrid[d, :]
        mpo = transferMPO(sites, sxList, syList, bulkMPOlist, leftMPOlist, rightMPOlist)
        if maxDim > 0
            psi = apply(mpo, psi, contractMethode=contractMethode, maxdim=maxDim)
        else
            psi = apply!(mpo, psi, contractMethode=contractMethode, cutoff=cutoff)
        end
        psilognorm = lognorm(psi)
        if psilognorm == -Inf # return zero norm null mps immediately
            print("warning: MPS norm = 0.0\n")
            return psi, 0.0
        end
        normalize!(psi)

    end
    return psi, 1.0
end


function contractDisorderTensorNetwork(
    sList::Vector{T},
    Lx::Integer,
    Ly::Integer,
    x::Integer,
    y::Integer,
    tA::Real;
    tB::Real=0.25π,
    contractmethod::String="densitymatrix",
    cutoff::Real=0,
    maxDim::Real=0,
    cornerpined::Bool=true) where {T<:Integer}


end
end
