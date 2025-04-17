"""
    RandomOperation <: Operation

An operation that applies a random operation from a list of operations with specified probabilities and random positions.
"""
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

"""
    push!(random::RandomOperation,
        op::Operation,
        positions::Matrix;
        probability,
        positionProbabilities)

Push a new operation to the list of operations in the `RandomOperation` object.
The operation is applied with a specified probability and the positions are given as a matrix.
The `positionProbabilities` argument specifies the probabilities for each position (column) in the matrix.
"""
function Base.push!(
    random::RandomOperation,
    op::Operation,
    positions::Matrix;
    probability=1.0,
    positionProbabilities=fill(1/size(positions,2), size(positions,2)))

    push!(random.operations, op)
    push!(random.probabilities, probability)
    push!(random.positions, positions)
    push!(random.positionProbabilities, positionProbabilities)

    return random
end
