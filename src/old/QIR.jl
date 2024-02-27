# Building blocks for the Quantum Intermediat Representation
abstract type AbstractBlock{D} end

abstract type PrimitiveBlock{D} <: AbstractBlock{D} end

abstract type CompositeBlock{D} <: AbstractBlock{D} end


struct GeneralMatrixBlock{D,T,MT<:AbstractMatrix{T}} <: PrimitiveBlock{D}
    m::Int
    n::Int
    mat::MT
    tag::String

    function GeneralMatrixBlock{D}(m::Int, n::Int, A::MT, tag::String="matblock(...)") where {D,T,MT<:AbstractMatrix{T}}
        (D^m, D^n) == size(A) ||
            throw(DimensionMismatch("expect a $(D^m) x $(D^n) matrix, got $(size(A))"))

        return new{D,T,MT}(m, n, A, tag)
    end
end

struct ProjectiveMeasurementBlock{D} <: PrimitiveBlock{D}

    function ProjectiveMeasurementBlock{D}() where {D}
        return new{D}()
    end
end

struct ChainBlock{D} <: CompositeBlock{D}
    n::Int
    blocks::Vector{AbstractBlock{D}}
    function ChainBlock(n::Int, blocks::Vector{<:AbstractBlock{D}}) where {D}
        # _check_block_sizes(blocks, n)
        return new{D}(n, blocks)
    end
end

struct ControlBlock{BT<:AbstractBlock,C,M} <: CompositeBlock{D}
    n::Int
    ctrl_locs::NTuple{C,Int}
    content::BT
    locs::NTuple{M,Int}
    function ControlBlock{BT,C,M}(n,
        ctrl_locs,
        block,
        locs,
    ) where {C,M,BT<:AbstractBlock}
        # @assert_locs_safe n (ctrl_locs..., locs...)
        # @assert nqudits(block) == M "number of locations doesn't match the size of block"
        # @assert block isa AbstractBlock "expect a block, got $(typeof(block))"
        new{BT,C,M}(n, ctrl_locs, block, locs)
    end
end
