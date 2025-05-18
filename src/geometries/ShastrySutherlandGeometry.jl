"""
A data structure representing a Shastry-Sutherland lattice geometry.

## Constructors
```julia
ShastrySutherlandGeometry(Periodic, sizeX::Integer, sizeY::Integer)
```
Construct a Shastry-Sutherland geometry with periodic boundary conditions.

## Arguments

- `sizeX::Integer`: The number of sites in the x direction
- `sizeY::Integer`: The number of sites in the y direction

## Examples

```julia
# Create a 4×4 Shastry-Sutherland lattice with periodic boundaries
geometry = ShastrySutherlandGeometry(Periodic, 4, 4)
```
"""
struct ShastrySutherlandGeometry{T<:BoundaryCondition} <: Geometry
    graph::Graph
    sizeX::Int64
    sizeY::Int64

    function ShastrySutherlandGeometry(type::Type{Periodic}, sizeX::Integer, sizeY::Integer)
        graph = Graphs.grid((sizeX, sizeY); periodic=true)
        g = new{type}(graph, sizeX, sizeY)
        for i in 1:sizeX
            for j in 1:sizeY
                if iseven(j)
                    if isodd(i)
                        Graphs.add_edge!(graph, to_linear(g,(i,j)), to_linear(g,(i+1,j+1)))
                    end
                else
                    if isodd(i)
                        Graphs.add_edge!(graph, to_linear(g, (i, j)), to_linear(g, (i - 1, j + 1)))
                    end
                end
            end
        end
        return g
    end
end

function bonds(geometry::ShastrySutherlandGeometry{Periodic}; type=:All)
    positions = Int64[]
    if type == :All
        for e in Graphs.edges(geometry.graph)
            push!(positions, Graphs.src(e))
            push!(positions, Graphs.dst(e))
        end
    elseif type == :DIAGONAL
        for e in Graphs.edges(geometry.graph)
            i_src, j_src = to_grid(geometry, Graphs.src(e))
            i_dst, j_dst = to_grid(geometry, Graphs.dst(e))
            if i_src != i_dst && j_src != j_dst
                push!(positions, Graphs.src(e))
                push!(positions, Graphs.dst(e))
            end
        end
    elseif type == :HORIZONTAL
        for e in Graphs.edges(geometry.graph)
            i_src, j_src = to_grid(geometry, Graphs.src(e))
            i_dst, j_dst = to_grid(geometry, Graphs.dst(e))
            if i_src != i_dst && j_src == j_dst
                push!(positions, Graphs.src(e))
                push!(positions, Graphs.dst(e))
            end
        end
    elseif type == :VERTICAL
        for e in Graphs.edges(geometry.graph)
            i_src, j_src = to_grid(geometry, Graphs.src(e))
            i_dst, j_dst = to_grid(geometry, Graphs.dst(e))
            if i_src == i_dst && j_src != j_dst
                push!(positions, Graphs.src(e))
                push!(positions, Graphs.dst(e))
            end
        end
    end
    return reshape(positions, 2, length(positions) ÷ 2)
end

function to_linear(geometry::ShastrySutherlandGeometry{Periodic}, (i, j)::NTuple{2,Int64})
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    return (mod1(i,sizeX)-1) * sizeY + mod1(j,sizeY)
end

function to_grid(geometry::ShastrySutherlandGeometry{Periodic}, i::Int64)
    sizeY = geometry.sizeY
    return (i-1) ÷ sizeY + 1,(i-1) % sizeY + 1
end


function visualize(io::IO, geometry::ShastrySutherlandGeometry{Periodic})
end

function subsystems(geometry::ShastrySutherlandGeometry{Periodic}, n::Integer=2; cutType=:VERTICAL)
    sites = zeros(Int64, geometry.sizeX*geometry.sizeY)
    if cutType == :HORIZONTAL
        geometry.sizeX % n == 0 || throw(ArgumentError("n=$n sub systems not possible."))
        for i in 1:geometry.sizeX
            sites[(i-1)*geometry.sizeY+1:i*geometry.sizeY] .= i:geometry.sizeX:geometry.sizeX*geometry.sizeY
        end
        return reshape(sites, geometry.sizeY*(geometry.sizeX÷n), n)
    elseif cutType == :VERTICAL
        geometry.sizeY % n == 0 || throw(ArgumentError("n=$n sub systems not possible."))
        sites .= 1:geometry.sizeX*geometry.sizeY
        return reshape(sites, geometry.sizeX*(geometry.sizeY÷n), n)
    end
    return reshape(sites, geometry.sizeX*(geometry.sizeY÷n), n)
end

function subsystem(geometry::ShastrySutherlandGeometry{Periodic}, l::Integer; cutType=:VERTICAL)
    if cutType == :HORIZONTAL
        sites = loops(geometry; type=:VERTICAL)
    elseif cutType == :VERTICAL
        sites = loops(geometry; type=:HORIZONTAL)
    end
    sub = @view sites[:, 1:l]
    return reshape(sub, length(sub), 1)
end

function loops(geometry::ShastrySutherlandGeometry{Periodic}; type=:HORIZONTAL)
    if type == :HORIZONTAL
        return reshape(1:geometry.sizeX*geometry.sizeY, geometry.sizeX, geometry.sizeY)
    elseif type == :VERTICAL
        return collect(reshape(1:geometry.sizeX*geometry.sizeY, geometry.sizeX, geometry.sizeY)')
    end
end
