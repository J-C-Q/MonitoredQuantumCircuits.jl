"""
    nPauli(paulistring::Vararg{Operation}) <: MeasurementOperation

A type representing a n qubit pauli parity measurement operation.
"""
struct NPauli{N} <: MeasurementOperation
    memory::NTuple{N,Int8}
    # paulistring::NTuple{N,Operation}
    # xs::BitVector
    # zs::BitVector
    function NPauli(paulistring::Vararg{Operation})
        @assert all(p -> (isa(p, X) || isa(p, Y) || isa(p, Z)), paulistring)
        N = length(paulistring)
        constructMemory = zeros(Int8, N)
        for (i, p) in enumerate(paulistring)
            if isa(p, X)
                constructMemory[i] = Int8(1)
            elseif isa(p, Y)
                constructMemory[i] = Int8(2)
            elseif isa(p, Z)
                constructMemory[i] = Int8(3)
            end
        end
        new{N}((constructMemory...,))
    end

    function NPauli(paulistring::Vararg{DataType})
        all(p -> (p == X || p == Y || p == Z), paulistring) || throw(ArgumentError("Only single qubit pauli operations."))
        N = length(paulistring)
        constructMemory = zeros(Int8, N)
        for (i, p) in enumerate(paulistring)
            if p == X
                constructMemory[i] = Int8(1)
            elseif p == Y
                constructMemory[i] = Int8(2)
            elseif p == Z
                constructMemory[i] = Int8(3)
            end
        end
        new{N}((constructMemory...,))
    end

    function NPauli(pauli::Operation, N::Integer)
        isa(pauli, X) || isa(pauli, Y) || isa(pauli, Z) || throw(ArgumentError("Only single qubit pauli operations."))
        num = Int8(0)
        if isa(pauli, X)
            num = Int8(1)
        elseif isa(pauli, Y)
            num = Int8(2)
        elseif isa(pauli, Z)
            num = Int8(3)
        end
        new{N}((fill(num, N)...,))
    end
end

function nQubits(p::NPauli)
    return length(p.memory)
end
function isClifford(::NPauli)
    return true
end
function Base.show(io::IO, p::NPauli)
    for (i, p) in enumerate(p.memory)
        if p == 1
            print(io, "X")
        elseif p == 2
            print(io, "Y")
        elseif p == 3
            print(io, "Z")
        end
    end
end
function getParameter(p::NPauli)
    floatParamter = Float64[]
    intParameter = p.memory
    return (floatParamter, intParameter)
end
function hasParameter(::Type{NPauli})
    return true
end
function hasParameter(::Type{NPauli}, ::Type{Int64})
    return true
end

function Base.:(==)(np1::NPauli, np2::NPauli)
    return all(np1.memory .== np2.memory)
end
function Base.hash(npauli::NPauli)
    return hash((npauli.memory))
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
