struct ByUnitCellGeometry{D} <: Geometry where {D}
    graph::Graph{Int64}
    size::NTuple{D,Int64}
    unit_cell_size::Int64

    function ByUnitCellGeometry(unit_cell::Graph{Int64},unit_cell_grid::Vector{NTuple{D,Int64}},cell_connections::NTuple{D, Vector{Edge{Int64}}}, size::NTuple{D,Int64}) where {D}
        ncells = prod(size)
        unit_cell_nqubits = nv(unit_cell)
        unit_cell_size = ntuple(i -> maximum([n[i] for n in unit_cell_grid]), D)
        size = ntuple(i -> size[i] * unit_cell_size[i], D)
        nqubits = ncells *   unit_cell_nqubits
        graph = Graphs.Graph(nqubits)
        for cellId in 1:ncells
            grid_cellId = _cellId_to_grid(cellId, D)
            for edge in edges(unit_cell)
                src = edge.src
                dst = edge.dst
                global_src = (cellId - 1) * unit_cell_size + src
                global_dst = (cellId - 1) * unit_cell_size + dst
                add_edge!(graph, global_src, global_dst)
            end
        end



        new(graph, size, unit_cell_size)
    end

end

function _cellId_to_grid(cellId::Int64, D::Int64)
    return ntuple(i -> div(cellId, prod(geometry.size[1:i])), D)
end

function to_linear(geometry::ByUnitCellGeometry{D}, inds::NTuple{D,Int64}) where {D}
    size = geometry.size
    unit_cell_size = geometry.unit_cell_size
    cellId = 1
    for i in 1:D
        cellId *= inds[i] - 1
    end
    linear_index = (cellId - 1) * unit_cell_size + inds[1]
    return linear_index
end

function to_grid(geometry::ByUnitCellGeometry{D}, i::Int64) where {D}

end

function neighbor(geometry::ByUnitCellGeometry{D}, i::Int64; direction::Symbol) where {D}

end
