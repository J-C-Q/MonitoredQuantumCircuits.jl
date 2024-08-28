
using StatsBase
# calculating tripartite mutual information
function TMI(bitstrings::Matrix{Bool})
    distribution(bitstrings)
end

function distribution(bitstrings::Matrix{Bool})
    bitstringTuples = [Tuple(bitstrings[:, i]) for i in 1:size(bitstrings, 2)]
    counts = countmap(bitstringTuples)
    bits = collect(keys(counts))
    frequency = collect(values(counts)) ./ size(bitstrings, 2)
    return (bits, frequency)
end


function shannonEntropy(distribution)
    return -sum(distribution .* log.(distribution))
end
