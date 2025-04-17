struct ChainGeometry{T<:BoundaryCondition} <: Geometry
    graph::Graph
    size::Int64
    function ChainGeometry(type::Type{Periodic}, size::Integer)
        graph = Graphs.cycle_graph(size)
        new{type}(graph, size)
    end
end

function bonds(geometry::ChainGeometry; type=:All)
    positions = Int64[]
    if type == :All
        for e in Graphs.edges(geometry.graph)
            push!(positions, Graphs.src(e))
            push!(positions, Graphs.dst(e))
        end
    elseif type == :A

    end
    return reshape(positions, 2, length(positions) ÷ 2)
end
function visualize(io::IO, geometry::ChainGeometry{Periodic})
end
function a_neighbor()

end

function qubits(geometry::ChainGeometry{Periodic})
    return reshape(collect(1:nQubits(geometry)), 1, nQubits(geometry))
end
