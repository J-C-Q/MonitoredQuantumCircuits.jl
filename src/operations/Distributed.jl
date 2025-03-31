struct DistributedOperation <: Operation
    operation::Operation
    positions::Matrix{Int64}
    probabilities::Vector{Float64}

    function DistributedOperation(operation::Operation, positions::Matrix, probabilities::Vector=ones(Float64, size(positions, 2)))
        new(operation, positions, probabilities)
    end
    function DistributedOperation(operation::Operation, positions::Matrix, probability::Float64)
        new(operation, positions, fill(probability, size(positions, 2)))
    end
end
