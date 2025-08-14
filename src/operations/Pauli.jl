"""
    MnPauli{N} <: MeasurementOperation

The MnPauli operation is a N-qubit measurement operation that measures the state of multiple qubits in the Pauli basis.
"""
struct MnPauli{N} <: MeasurementOperation
    memory::NTuple{N,Int8}
end

# -------- helper for the element code --------
@inline _code(::X) = Int8(1)
@inline _code(::Y) = Int8(2)
@inline _code(::Z) = Int8(3)

# 1. From a tuple/Vararg – already non‑allocating
MnPauli(paulis::Vararg{Operation,N}) where N =
    MnPauli{N}(ntuple(i -> _code(paulis[i]), Val(N)))

MnPauli(paulis::Vararg{DataType,N}) where N =
    MnPauli{N}(ntuple(i -> _code(paulis[i]()), Val(N)))

MnPauli() = MnPauli{0}(NTuple{0,Int8}())

# 2. From a single Pauli and a **type‑level** length
MnPauli{N}(pauli::Operation) where N =
    MnPauli{N}(ntuple(_ -> _code(pauli), Val(N)))

# 3. Convenience wrapper that still avoids allocation
MnPauli(pauli::Operation, ::Val{N}) where N = MnPauli{N}(pauli)


function Base.show(io::IO, p::MnPauli)
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

function Base.:(==)(np1::MnPauli, np2::MnPauli)
    return all(np1.memory .== np2.memory)
end
function Base.hash(npauli::MnPauli)
    return hash((npauli.memory))
end

function nQubits(p::MnPauli)
    return length(p.memory)
end
function isClifford(::MnPauli)
    return true
end
function nAncilla(::MnPauli)
    return 1
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
