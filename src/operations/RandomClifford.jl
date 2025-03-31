struct RandomClifford <: Operation
    nqubits::Int64
end

function Base.:(==)(np1::RandomClifford, np2::RandomClifford)
    return np1.nqubits == np2.nqubits
end
function Base.hash(random_clifford::RandomClifford)
    return hash(random_clifford.nqubits)
end
