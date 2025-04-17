struct Defect
    i::Int64
    direction::Symbol
    function Defect(start::Int64, direction::Symbol)
        direction in [:Up, :Down, :Left, :Right] || throw(ArgumentError("Invalid defect direction: $direction"))
        return new(start, direction)
    end
end

struct SquareGeometry{T<:BoundaryCondition} <: Geometry
    graph::Graph
    sizeX::Int64
    sizeY::Int64

    function SquareGeometry(type::Type{Periodic}, sizeX::Integer, sizeY::Integer)
        graph = Graphs.grid((sizeX,sizeY); periodic=true)
        new{type}(graph, sizeX, sizeY)
    end
    function SquareGeometry(type::Type{Open}, sizeX::Integer, sizeY::Integer)
        graph = Graphs.grid((sizeX,sizeY); periodic=false)
        new{type}(graph, sizeX, sizeY)
    end
    function SquareGeometry(type::Type{Open}, sizeX::Integer, sizeY::Integer, defects::Vector{Defect})
        graph = Graphs.grid((sizeX,sizeY); periodic=false)
        for defect in defects
            if defect.direction == :Up
                Graphs.add_edge!(graph, defect.i, defect.i + sizeX)
            elseif defect.direction == :Down
                Graphs.add_edge!(graph, defect.i, defect.i - sizeX)
            elseif defect.direction == :Left
                Graphs.add_edge!(graph, defect.i, defect.i - 1)
            elseif defect.direction == :Right
                Graphs.add_edge!(graph, defect.i, defect.i + 1)
            end
        end
        new{type}(graph, sizeX, sizeY)
    end
end



function to_linear(geometry::SquareGeometry{Periodic}, (i, j)::NTuple{2,Int64})
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    return (mod1(i,sizeX)-1) * sizeY + mod1(j,sizeY)
end

function to_grid(geometry::SquareGeometry{Periodic}, i::Int64)
    sizeY = geometry.sizeY
    return (i-1) ÷ sizeY + 1,(i-1) % sizeY + 1
end

function neighbor(geometry::SquareGeometry{Periodic}, i::Int64; direction::Symbol)
    direction in [:Left, :Right, :Up, :Down] || throw(ArgumentError("Invalid direction: $direction"))
    if direction == :Left
        return kitaevX_neighbor(geometry, i)
    elseif direction == :Right
        return kitaevY_neighbor(geometry, i)
    elseif direction == :Up
        return kitaevZ_neighbor(geometry, i)
    elseif direction == :Down
        return kekuleRed_neighbor(geometry, i)
    end
end

function left_neighbor(geometry::SquareGeometry{Periodic}, i::Int64)
    i,j = to_grid(geometry, i)

    return neighbor(geometry, i; direction=:Left)
end

function bonds(geometry::SquareGeometry; type=:All)
    positions = Int64[]
    if type == :All
        for e in Graphs.edges(geometry.graph)
            push!(positions, Graphs.src(e))
            push!(positions, Graphs.dst(e))
        end
    elseif type == :HORIZONTAL
        for e in Graphs.edges(geometry.graph)
            i_src, j_src = to_grid_square(Graphs.src(e), geometry.sizeX, geometry.sizeY)
            i_dst, j_dst = to_grid_square(Graphs.dst(e), geometry.sizeX, geometry.sizeY)
            if i_src != i_dst && j_src == j_dst
                push!(positions, Graphs.src(e))
                push!(positions, Graphs.dst(e))
            end
        end
    elseif type == :VERTICAL
        for e in Graphs.edges(geometry.graph)
            i_src, j_src = to_grid_square(Graphs.src(e), geometry.sizeX, geometry.sizeY)
            i_dst, j_dst = to_grid_square(Graphs.dst(e), geometry.sizeX, geometry.sizeY)
            if i_src == i_dst && j_src != j_dst
                push!(positions, Graphs.src(e))
                push!(positions, Graphs.dst(e))
            end
        end
    end
    return reshape(positions, 2, length(positions) ÷ 2)
end


function visualize(io::IO, geometry::SquareGeometry{Periodic})
end
