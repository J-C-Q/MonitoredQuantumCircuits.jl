"""
    DistributedOperation <: Operation

An operation that applies a specified operation at multiple positions with given probabilities.
"""
struct DistributedOperation <: Operation
    operation::Operation
    positions::Matrix{Int64}
    probabilities::Vector{Float64}

    """
        DistributedOperation(operation::Operation, positions::Matrix, probability::Vector{Float64})

    Create a `DistributedOperation` with a specified operation, positions, and probabilities for each position.
    """
    function DistributedOperation(operation::Operation, positions::Matrix, probabilities::Vector=ones(Float64, size(positions, 2)))
        new(operation, positions, probabilities)
    end

    """
        DistributedOperation(operation::Operation, positions::Matrix, probability::Float64)

    Create a `DistributedOperation` with a specified operation, positions, and a single probability for all positions.
    """
    function DistributedOperation(operation::Operation, positions::Matrix, probability::Float64)
        new(operation, positions, fill(probability, size(positions, 2)))
    end
end
