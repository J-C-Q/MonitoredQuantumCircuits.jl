abstract type Result end

struct SampleResult <: Result
    result::Matrix{Bool}
    qubitMap::Vector{Int64}
end
