struct RandomOperation <: Operation
    operations::Vector{Operation}
    probabilities::Vector{Float64}
    positions::Vector{Matrix{Int64}}
    positionProbabilities::Vector{Vector{Float64}}
    function RandomOperation()
        operations = Operation[]
        probabilities = Float64[]
        positions = Matrix{Int64}[]
        positionProbabilities = Vector{Float64}[]
        new(operations, probabilities, positions, positionProbabilities)
    end
end


function Base.push!(
    random::RandomOperation,
    op::Operation,
    positions::Matrix;
    probability=1.0,
    positionProbabilities=fill(1/size(positions,2), size(positions,2)))

    push!(random.operations, op)
    if probability ≈ 1.0 && !isempty(random.probabilities)
        random.probabilities .*= length(random.probabilities)/(length(random.probabilities) + 1)
        push!(random.probabilities, 1/(length(random.probabilities)+1))
    else
        push!(random.probabilities, probability)
    end
    push!(random.positions, positions)
    push!(random.positionProbabilities, positionProbabilities)

    return random
end
