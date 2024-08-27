abstract type Result end

struct SampleResult <: Result
    result::Matrix{Bool} # nMeasurements x nShots
    qubitMap::Vector{Int64}
end

Base.getindex(result::SampleResult, i::Int) = result.result[:, i]
