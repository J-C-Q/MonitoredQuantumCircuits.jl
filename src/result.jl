# abstract type Result end



# struct SampleResult <: Result
#     result::Matrix{Bool} # nMeasurements x nShots
#     qubitMap::Vector{Int64}
# end

# Base.getindex(result::SampleResult, i::Int) = result.result[i, :]
# Base.getindex(result::SampleResult, r::UnitRange) = result.result[r, :]

# Base.lastindex(result::SampleResult) = size(result.result, 1)

abstract type Result end
#     measurementOutcomes::Matrix{Bool}
#     measuredQubits::Vector{Int}
#     nativeResult::T
# end
