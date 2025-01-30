"""
    nPauli(paulistring::Vararg{Operation}) <: MeasurementOperation

A type representing a n qubit pauli parity measurement operation.
"""
struct nPauli{N} <: MeasurementOperation
    paulistring::NTuple{N,Operation}
    xs::Vector{Bool}
    zs::Vector{Bool}
    function nPauli(paulistring::Vararg{Operation})
        @assert all(p -> (isa(p, X) || isa(p, Y) || isa(p, Z)), paulistring)
        xs = zeros(Bool, length(paulistring))
        zs = zeros(Bool, length(paulistring))
        for (i, p) in enumerate(paulistring)
            if isa(p, X)
                xs[i] = true
            elseif isa(p, Z)
                zs[i] = true
            elseif isa(p, Y)
                xs[i] = true
                zs[i] = true
            end
        end
        new{length(paulistring)}(paulistring, xs, zs)
    end
end

function Base.string(o::Operation)
    return string(nameof(typeof(o)))
end

function nQubits(p::nPauli)
    return length(p.paulistring)
end
function isClifford(::nPauli)
    return true
end

# function connectionGraph(::XX)
#     # return the connection graph of the operation
#     return path_graph(3)
# end
# function plotPositions(::XX)
#     return [(0, 0), (1, 0), (2, 0)]
# end

# function color(::XX)
#     return "#CB3C33"
# end

# function isAncilla(::XX, qubit::Integer)
#     0 < qubit <= nQubits(XX()) || throw(ArgumentError("qubit $qubit is not a valid qubit for the XX operation."))
#     return qubit == 2
# end

# function nMeasurements(::XX)
#     return 1
# end
