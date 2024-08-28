
using StatsBase
# calculating tripartite mutual information
function TMI(bitstrings::Matrix{Bool}, A, B, C)
    dist = distribution(bitstrings)
    S_A = shannonEntropy(marginalize(dist, A)[2])
    S_B = shannonEntropy(marginalize(dist, B)[2])
    S_C = shannonEntropy(marginalize(dist, C)[2])
    S_AB = shannonEntropy(marginalize(dist, A ∪ B)[2])
    S_AC = shannonEntropy(marginalize(dist, A ∪ C)[2])
    S_BC = shannonEntropy(marginalize(dist, B ∪ C)[2])
    S_ABC = shannonEntropy(marginalize(dist, A ∪ B ∪ C)[2])

    tmi = S_A + S_B + S_C - S_AB - S_AC - S_BC + S_ABC

    return tmi
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

function marginalize(prob_dist, subsystem_indices)
    subsystems = [Tuple([p[i] for i in subsystem_indices]) for p in prob_dist[1]]
    bits = unique(subsystems)
    frequency = zeros(length(bits))
    for (i, sub) in enumerate(bits)
        indices = findall(x -> x == sub, subsystems)
        frequency[i] = sum(prob_dist[2][indices])
    end
    return (bits, frequency)
end
