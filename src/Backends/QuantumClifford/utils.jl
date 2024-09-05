struct nHot <: AbstractVector{Bool}
    is::Vector{Int64}
    n::Int64
end

Base.size(nh::nHot) = (nh.n,)
Base.getindex(nh::nHot, i::Int) = i in nh.is

function Base.getindex(nh::nHot, r::UnitRange)
    [i in nh.is for i in r]
end

Base.lastindex(nh::nHot) = nh.n

Base.length(nh::nHot) = nh.n
