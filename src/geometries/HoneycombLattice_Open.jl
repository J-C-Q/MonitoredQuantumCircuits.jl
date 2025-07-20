"""
A data structure representing a honeycomb lattice geometry.

## Constructors
```julia
HoneycombGeometry(Periodic, sizeX::Integer, sizeY::Integer)
```
Create a honeycomb geometry with periodic boundary conditions.
```julia
HoneycombGeometry(Open, sizeX::Integer, sizeY::Integer)
```
Create a honeycomb geometry with open boundary conditions.

## Arguments

- `sizeX::Integer`: Width of the lattice
- `sizeY::Integer`: Height of the lattice (must be even)

## Examples

```julia
# Create a 4×4 honeycomb lattice with periodic boundaries
geometry = HoneycombGeometry(Periodic, 4, 4)

# Create a 6×6 honeycomb lattice with open boundaries
geometry = HoneycombGeometry(Open, 6, 6)
```
"""
struct HoneycombGeometry{T<:BoundaryCondition} <: Geometry
    graph::Graphs.SimpleGraphs.SimpleGraph{Int64}
    sizeX::Int64
    sizeY::Int64
    bonds::Vector{Bond{Int64}}
    kitaevX_bonds::Vector{Bond{Int64}}
    kitaevY_bonds::Vector{Bond{Int64}}
    kitaevZ_bonds::Vector{Bond{Int64}}
    kekuleRed_bonds::Vector{Bond{Int64}}
    kekuleGreen_bonds::Vector{Bond{Int64}}
    kekuleBlue_bonds::Vector{Bond{Int64}}
    plaquettes::Matrix{Int64}
    loopsXY::Matrix{Int64}
    loopsXZ::Matrix{Int64}
    loopsYZ::Matrix{Int64}

    function HoneycombGeometry(type::Type{Periodic}, sizeX::Integer, sizeY::Integer)
        sizeX = sizeX * 2
        sizeX > 0 || throw(ArgumentError("size must be positive"))
        sizeY > 0 || throw(ArgumentError("size must be positive"))
        sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
        graph = SimpleGraph(sizeX * sizeY)
        sizes = (sizeX, sizeY)
        for j in 1:sizeY
            for i in 1:2:sizeX
                add_edge!(graph, to_linear(sizes, (i, j)), to_linear(sizes, (i + 1, j)))
            end
        end
        for j in 1:sizeY
            for i in 2:2:sizeX
                add_edge!(graph, to_linear(sizes, (i, j)), to_linear(sizes, (i + 1, j)))
            end
        end
        for j in 1:sizeY
            for i in 2:2:sizeX
                add_edge!(graph, to_linear(sizes, (i, j)), to_linear(sizes, (i - 1, j + 1)))
            end
        end
        bonds = collect()
        return new{Periodic}(graph, sizeX, sizeY)
    end
    function HoneycombGeometry(type::Type{Open}, sizeX::Integer, sizeY::Integer)
        sizeX = sizeX * 2
        sizeX > 0 || throw(ArgumentError("size must be positive"))
        sizeY > 0 || throw(ArgumentError("size must be positive"))
        sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
        graph = SimpleGraph(sizeX * sizeY)

        g = new{Open}(graph, sizeX, sizeY)

        for j in 1:sizeY
            for i in 1:2:sizeX-1
                add_edge!(graph, to_linear(g, (i, j)), to_linear(g, (i + 1, j)))
            end
        end
        for j in 1:sizeY
            for i in 2:2:sizeX-1
                add_edge!(graph, to_linear(g, (i, j)), to_linear(g, (i + 1, j)))
            end
        end
        for j in 1:sizeY-1
            for i in 2:2:sizeX
                add_edge!(graph, to_linear(g, (i, j)), to_linear(g, (i - 1, j + 1)))
            end
        end

        return g
    end
end

function visualize(io::IO, geometry::HoneycombGeometry)
end

function to_linear(geometry::HoneycombGeometry, (i, j)::NTuple{2,Int64})
    return mod1(i, geometry.sizeX) + geometry.sizeX * (mod1(j, geometry.sizeY) - 1)
end
function to_linear((sizeX,sizeY)::Tuple{Int64,Int64}, (i, j)::NTuple{2,Int64})
    return mod1(i, sizeX) + sizeX * (mod1(j, sizeY) - 1)
end

function to_grid(geometry::HoneycombGeometry, i::Int64)
    return (mod1(i, geometry.sizeX), div(i - 1, geometry.sizeX) + 1)
end
function to_grid((sizeX,sizeY)::Tuple{Int64,Int64}, i::Int64)
    return (mod1(i, sizeX), div(i - 1, sizeX) + 1)
end

function collectBonds(::Type{HoneycombGeometry{Periodic}}, graph::Graph)
    bonds = Vector{Bond{Int64}}(undef, ne(graph))
    kitaevX_bonds = Bond{Int64}[]
    kitaevY_bonds = Bond{Int64}[]
    kitaevZ_bonds = Bond{Int64}[]
    kekuleRed_bonds = Bond{Int64}[]
    kekuleGreen_bonds = Bond{Int64}[]
    kekuleBlue_bonds = Bond{Int64}[]

    for (i,e) in enumerate(edges(graph))
        src, dst = src(e), dst(e)
        bonds[i] = Bond(src, dst)
        if isKitaevX(geometry, (src, dst))
            push!(kitaevX_bonds, (src, dst))
        elseif isKitaevY(geometry, (src, dst))
            push!(kitaevY_bonds, (src, dst))
        elseif isKitaevZ(geometry, (src, dst))
            push!(kitaevZ_bonds, (src, dst))
        elseif isKekuleRed(geometry, (src, dst))
            push!(kekuleRed_bonds, (src, dst))
        elseif isKekuleGreen(geometry, (src, dst))
            push!(kekuleGreen_bonds, (src, dst))
        elseif isKekuleBlue(geometry, (src, dst))
            push!(kekuleBlue_bonds, (src, dst))
        end
    end

end










function neighbor(geometry::HoneycombGeometry{Periodic}, i::Int64, direction::Symbol)
    direction in [:X, :Y, :Z, :Red, :Green, :Blue] || throw(ArgumentError("Invalid direction: $direction"))
    if direction == :X
        return kitaevX_neighbor(geometry, i)
    elseif direction == :Y
        return kitaevY_neighbor(geometry, i)
    elseif direction == :Z
        return kitaevZ_neighbor(geometry, i)
    elseif direction == :Red
        return kekuleRed_neighbor(geometry, i)
    elseif direction == :Green
        return kekuleGreen_neighbor(geometry, i)
    elseif direction == :Blue
        return kekuleBlue_neighbor(geometry, i)
    end
end

function neighbor(geometry::HoneycombGeometry{Periodic}, i::Int64, direction::UInt8)
    if direction == UInt8(1)
        return kitaevX_neighbor(geometry, i)
    elseif direction == UInt8(2)
        return kitaevY_neighbor(geometry, i)
    elseif direction == UInt8(3)
        return kitaevZ_neighbor(geometry, i)
    end
end


function kitaevX(geometry::HoneycombGeometry{Periodic})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    bonds = Tuple{Int64,Int64}[]
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    for j in 1:sizeY
        for i in 1:2:sizeX
            push!(bonds, (to_linear(geometry, (i, j)), to_linear(geometry, (i + 1, j))))
        end
    end
    return bonds
end

function kitaevY(geometry::HoneycombGeometry{Periodic})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    bonds = Tuple{Int64,Int64}[]
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    for j in 1:sizeY
        for i in 2:2:sizeX
            push!(bonds, (to_linear(geometry, (i, j)), to_linear(geometry, (i + 1, j))))
        end
    end
    return bonds
end

function kitaevZ(geometry::HoneycombGeometry{Periodic})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    bonds = Tuple{Int64,Int64}[]
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    for j in 1:sizeY
        for i in 2:2:sizeX
            push!(bonds, (to_linear(geometry, (i, j)), to_linear(geometry, (i - 1, j + 1))))
        end
    end
    return bonds
end

function kitaevX(geometry::HoneycombGeometry{Open})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    bonds = Tuple{Int64,Int64}[]
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    for j in 1:sizeY
        for i in 1:2:sizeX-1
            push!(bonds, (to_linear(geometry, (i, j)), to_linear(geometry, (i + 1, j))))
        end
    end
    return bonds
end

function kitaevY(geometry::HoneycombGeometry{Open})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    bonds = Tuple{Int64,Int64}[]
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    for j in 1:sizeY
        for i in 2:2:sizeX-1
            push!(bonds, (to_linear(geometry, (i, j)), to_linear(geometry, (i + 1, j))))
        end
    end
    return bonds
end

function kitaevZ(geometry::HoneycombGeometry{Open})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    bonds = Tuple{Int64,Int64}[]
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    for j in 1:sizeY-1
        for i in 2:2:sizeX
            push!(bonds, (to_linear(geometry, (i, j)), to_linear(geometry, (i - 1, j + 1))))
        end
    end
    return bonds
end

function isKitaevX(geometry::HoneycombGeometry, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    neighbor1 = kitaevX_neighbor(geometry, bond[1])
    neighbor2 = kitaevX_neighbor(geometry, bond[2])
    if (neighbor2, neighbor1) == bond
        return true
    end
    return false
end



function isKitaevY(geometry::HoneycombGeometry, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    neighbor1 = kitaevY_neighbor(geometry, bond[1])
    neighbor2 = kitaevY_neighbor(geometry, bond[2])
    if (neighbor2, neighbor1) == bond
        return true
    end
    return false
end

function isKitaevZ(geometry::HoneycombGeometry, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    neighbor1 = kitaevZ_neighbor(geometry, bond[1])
    neighbor2 = kitaevZ_neighbor(geometry, bond[2])
    if (neighbor2, neighbor1) == bond
        return true
    end
    return false
end

function isKekuleRed(geometry::HoneycombGeometry, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    neighbor1 = kekuleRed_neighbor(geometry, bond[1])
    neighbor2 = kekuleRed_neighbor(geometry, bond[2])
    if (neighbor2, neighbor1) == bond
        return true
    end
    return false
end

function isKekuleGreen(geometry::HoneycombGeometry, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    neighbor1 = kekuleGreen_neighbor(geometry, bond[1])
    neighbor2 = kekuleGreen_neighbor(geometry, bond[2])
    if (neighbor2, neighbor1) == bond
        return true
    end
    return false
end

function isKekuleBlue(geometry::HoneycombGeometry, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    neighbor1 = kekuleBlue_neighbor(geometry, bond[1])
    neighbor2 = kekuleBlue_neighbor(geometry, bond[2])
    if (neighbor2, neighbor1) == bond
        return true
    end
    return false
end



function kitaevX_neighbor(geometry::HoneycombGeometry{Open}, site::Integer)
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    i, j = to_grid(geometry, site)
    if isodd(i)
        new = to_linear(geometry, (i + 1, j))
        if (site,new) in edges(geometry.graph)
            return new
        else
            return site
        end
    else
        new = to_linear(geometry,(i - 1, j))
        if (site,new) in edges(geometry.graph)
            return new
        else
            return site
        end
    end
end

function kitaevX_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    i, j = to_grid(geometry, site)
    if isodd(i)
        return to_linear(geometry, (i + 1, j))
    else
        return to_linear(geometry,(i - 1, j))
    end
end



function kitaevY_neighbor(geometry::HoneycombGeometry{Open}, site::Integer)
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    i, j = to_grid(geometry, site)
    if iseven(i)
        new = to_linear(geometry, (i + 1, j))
        if (site,new) in edges(geometry.graph)
            return new
        else
            return site
        end
    else
        new = to_linear(geometry, (i - 1, j))
        if (site,new) in edges(geometry.graph)
            return new
        else
            return site
        end
    end
end

function kitaevY_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    i, j = to_grid(geometry, site)
    if iseven(i)
        return to_linear(geometry, (i + 1, j))
    else
        return to_linear(geometry, (i - 1, j))
    end
end

function kitaevZ_neighbor(geometry::HoneycombGeometry{Open}, site::Integer)
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    i, j = to_grid(geometry, site)
    if iseven(i)
        new = to_linear(geometry, (i - 1, j + 1))
        if (site,new) in edges(geometry.graph)
            return new
        else
            return site
        end
    else
        new = to_linear(geometry, (i + 1, j - 1))
        if (site,new) in edges(geometry.graph)
            return new
        else
            return site
        end
    end
end

function kitaevZ_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    i, j = to_grid(geometry, site)
    if iseven(i)
        return to_linear(geometry, (i - 1, j + 1))
    else
        return to_linear(geometry, (i + 1, j - 1))
    end
end


function kekuleRed_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    i, j = to_grid(geometry, site)
    j = mod1(j, 3)
    if iseven(i)
        i = mod1(i, 6) ÷ 2
        if i == 1
            if j == 1
                return kitaevZ_neighbor(geometry, site)
            elseif j == 2
                return kitaevY_neighbor(geometry, site)
            elseif j == 3
                return kitaevX_neighbor(geometry, site)
            end
        elseif i == 2
            if j == 1
                return kitaevX_neighbor(geometry, site)
            elseif j == 2
                return kitaevZ_neighbor(geometry, site)
            elseif j == 3
                return kitaevY_neighbor(geometry, site)
            end
        elseif i == 3
            if j == 1
                return kitaevY_neighbor(geometry, site)
            elseif j == 2
                return kitaevX_neighbor(geometry, site)
            elseif j == 3
                return kitaevZ_neighbor(geometry, site)
            end
        end
    else
        i = mod1(i + 1, 6) ÷ 2
        if i == 1
            if j == 1
                return kitaevY_neighbor(geometry, site)
            elseif j == 2
                return kitaevZ_neighbor(geometry, site)
            elseif j == 3
                return kitaevX_neighbor(geometry, site)
            end
        elseif i == 2
            if j == 1
                return kitaevX_neighbor(geometry, site)
            elseif j == 2
                return kitaevY_neighbor(geometry, site)
            elseif j == 3
                return kitaevZ_neighbor(geometry, site)
            end
        elseif i == 3
            if j == 1
                return kitaevZ_neighbor(geometry, site)
            elseif j == 2
                return kitaevX_neighbor(geometry, site)
            elseif j == 3
                return kitaevY_neighbor(geometry, site)
            end
        end
    end
end

function kekuleGreen_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    i, j = to_grid(geometry, site)
    j = mod1(j, 3)
    if iseven(i)
        i = mod1(i, 6) ÷ 2
        if i == 1
            if j == 1
                return kitaevY_neighbor(geometry, site)
            elseif j == 2
                return kitaevX_neighbor(geometry, site)
            elseif j == 3
                return kitaevZ_neighbor(geometry, site)
            end
        elseif i == 2
            if j == 1
                return kitaevZ_neighbor(geometry, site)
            elseif j == 2
                return kitaevY_neighbor(geometry, site)
            elseif j == 3
                return kitaevX_neighbor(geometry, site)
            end
        elseif i == 3
            if j == 1
                return kitaevX_neighbor(geometry, site)
            elseif j == 2
                return kitaevZ_neighbor(geometry, site)
            elseif j == 3
                return kitaevY_neighbor(geometry, site)
            end
        end
    else
        i = mod1(i + 1, 6) ÷ 2
        if i == 1
            if j == 1
                return kitaevZ_neighbor(geometry, site)
            elseif j == 2
                return kitaevX_neighbor(geometry, site)
            elseif j == 3
                return kitaevY_neighbor(geometry, site)
            end
        elseif i == 2
            if j == 1
                return kitaevY_neighbor(geometry, site)
            elseif j == 2
                return kitaevZ_neighbor(geometry, site)
            elseif j == 3
                return kitaevX_neighbor(geometry, site)
            end
        elseif i == 3
            if j == 1
                return kitaevX_neighbor(geometry, site)
            elseif j == 2
                return kitaevY_neighbor(geometry, site)
            elseif j == 3
                return kitaevZ_neighbor(geometry, site)
            end
        end
    end
end

function kekuleBlue_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    i, j = to_grid(geometry, site)
    j = mod1(j, 3)
    if iseven(i)
        i = mod1(i, 6) ÷ 2
        if i == 1
            if j == 1
                return kitaevX_neighbor(geometry, site)
            elseif j == 2
                return kitaevZ_neighbor(geometry, site)
            elseif j == 3
                return kitaevY_neighbor(geometry, site)
            end
        elseif i == 2
            if j == 1
                return kitaevY_neighbor(geometry, site)
            elseif j == 2
                return kitaevX_neighbor(geometry, site)
            elseif j == 3
                return kitaevZ_neighbor(geometry, site)
            end
        elseif i == 3
            if j == 1
                return kitaevZ_neighbor(geometry, site)
            elseif j == 2
                return kitaevY_neighbor(geometry, site)
            elseif j == 3
                return kitaevX_neighbor(geometry, site)
            end
        end
    else
        i = mod1(i + 1, 6) ÷ 2
        if i == 1
            if j == 1
                return kitaevX_neighbor(geometry, site)
            elseif j == 2
                return kitaevY_neighbor(geometry, site)
            elseif j == 3
                return kitaevZ_neighbor(geometry, site)
            end
        elseif i == 2
            if j == 1
                return kitaevZ_neighbor(geometry, site)
            elseif j == 2
                return kitaevX_neighbor(geometry, site)
            elseif j == 3
                return kitaevY_neighbor(geometry, site)
            end
        elseif i == 3
            if j == 1
                return kitaevY_neighbor(geometry, site)
            elseif j == 2
                return kitaevZ_neighbor(geometry, site)
            elseif j == 3
                return kitaevX_neighbor(geometry, site)
            end
        end
    end
end

# function random_bond(geometry::HoneycombGeometry; type=:All)
#     qubit = random_qubit(geometry)
#     if type == :X
#         return (qubit,kitaevX_neighbor(geometry,qubit))
#     elseif type == :Y
#         return (qubit,kitaevY_neighbor(geometry,qubit))
#     elseif type == :Z
#         return (qubit,kitaevZ_neighbor(geometry,qubit))
#     elseif type == :Red
#         return (qubit,kekuleRed_neighbor(geometry,qubit))
#     elseif type == :Green
#         return (qubit,kekuleGreen_neighbor(geometry,qubit))
#     elseif type == :Blue
#         return (qubit,kekuleBlue_neighbor(geometry,qubit))
#     elseif type == :All
#         type = rand([:X, :Y, :Z, :Red, :Green, :Blue])
#         return random_bond(geometry; type=type)
#     end
# end

function random_kitaevX_bond(geometry::HoneycombGeometry)
    qubit = random_qubit(geometry)
    return (qubit, kitaevX_neighbor(geometry, qubit))
end
function random_kitaevY_bond(geometry::HoneycombGeometry)
    qubit = random_qubit(geometry)
    return (qubit, kitaevY_neighbor(geometry, qubit))
end
function random_kitaevZ_bond(geometry::HoneycombGeometry)
    qubit = random_qubit(geometry)
    return (qubit, kitaevZ_neighbor(geometry, qubit))
end
function random_kekuleRed_bond(geometry::HoneycombGeometry)
    qubit = random_qubit(geometry)
    return (qubit, kekuleRed_neighbor(geometry, qubit))
end
function random_kekuleGreen_bond(geometry::HoneycombGeometry)
    qubit = random_qubit(geometry)
    return (qubit, kekuleGreen_neighbor(geometry, qubit))
end
function random_kekuleBlue_bond(geometry::HoneycombGeometry)
    qubit = random_qubit(geometry)
    return (qubit, kekuleBlue_neighbor(geometry, qubit))
end

# function bonds(geometry::HoneycombGeometry; kitaevType=:All, kekuleType=:All)
#     positions = Int64[]
#     if kitaevType == :All
#         if kekuleType == :All
#             for e in Graphs.edges(geometry.graph)
#                 push!(positions, Graphs.src(e))
#                 push!(positions, Graphs.dst(e))
#             end
#         elseif kekuleType == :Red
#             for e in Graphs.edges(geometry.graph)
#                 bond = (Graphs.src(e), Graphs.dst(e))
#                 if isKekuleRed(geometry, bond)
#                     push!(positions, bond[1])
#                     push!(positions, bond[2])
#                 end
#             end
#         elseif kekuleType == :Green
#             for e in Graphs.edges(geometry.graph)
#                 bond = (Graphs.src(e), Graphs.dst(e))
#                 if isKekuleGreen(geometry, bond)
#                     push!(positions, bond[1])
#                     push!(positions, bond[2])
#                 end
#             end
#         elseif kekuleType == :Blue
#             for e in Graphs.edges(geometry.graph)
#                 bond = (Graphs.src(e), Graphs.dst(e))
#                 if isKekuleBlue(geometry, bond)
#                     push!(positions, bond[1])
#                     push!(positions, bond[2])
#                 end
#             end
#         end
#     elseif kitaevType == :X
#         if kekuleType == :All
#             for e in Graphs.edges(geometry.graph)
#                 bond = (Graphs.src(e), Graphs.dst(e))
#                 if isKitaevX(geometry, bond)
#                     push!(positions, Graphs.src(e))
#                     push!(positions, Graphs.dst(e))
#                 end
#             end
#         elseif kekuleType == :Red
#             for e in Graphs.edges(geometry.graph)
#                 bond = (Graphs.src(e), Graphs.dst(e))
#                 if isKitaevX(geometry, bond) && isKekuleRed(geometry, bond)
#                     push!(positions, bond[1])
#                     push!(positions, bond[2])
#                 end
#             end
#         elseif kekuleType == :Green
#             for e in Graphs.edges(geometry.graph)
#                 bond = (Graphs.src(e), Graphs.dst(e))
#                 if isKitaevX(geometry, bond) && isKekuleGreen(geometry, bond)
#                     push!(positions, bond[1])
#                     push!(positions, bond[2])
#                 end
#             end
#         elseif kekuleType == :Blue
#             for e in Graphs.edges(geometry.graph)
#                 bond = (Graphs.src(e), Graphs.dst(e))
#                 if isKitaevX(geometry, bond) && isKekuleBlue(geometry, bond)
#                     push!(positions, bond[1])
#                     push!(positions, bond[2])
#                 end
#             end
#         end
#     elseif kitaevType == :Y
#         if kekuleType == :All
#             for e in Graphs.edges(geometry.graph)
#                 bond = (Graphs.src(e), Graphs.dst(e))
#                 if isKitaevY(geometry, bond)
#                     push!(positions, Graphs.src(e))
#                     push!(positions, Graphs.dst(e))
#                 end
#             end
#         elseif kekuleType == :Red
#             for e in Graphs.edges(geometry.graph)
#                 bond = (Graphs.src(e), Graphs.dst(e))
#                 if isKitaevY(geometry, bond) && isKekuleRed(geometry, bond)
#                     push!(positions, bond[1])
#                     push!(positions, bond[2])
#                 end
#             end
#         elseif kekuleType == :Green
#             for e in Graphs.edges(geometry.graph)
#                 bond = (Graphs.src(e), Graphs.dst(e))
#                 if isKitaevY(geometry, bond) && isKekuleGreen(geometry, bond)
#                     push!(positions, bond[1])
#                     push!(positions, bond[2])
#                 end
#             end
#         elseif kekuleType == :Blue
#             for e in Graphs.edges(geometry.graph)
#                 bond = (Graphs.src(e), Graphs.dst(e))
#                 if isKitaevY(geometry, bond) && isKekuleBlue(geometry, bond)
#                     push!(positions, bond[1])
#                     push!(positions, bond[2])
#                 end
#             end
#         end
#     elseif kitaevType == :Z
#         if kekuleType == :All
#             for e in Graphs.edges(geometry.graph)
#                 bond = (Graphs.src(e), Graphs.dst(e))
#                 if isKitaevZ(geometry, bond)
#                     push!(positions, Graphs.src(e))
#                     push!(positions, Graphs.dst(e))
#                 end
#             end
#         elseif kekuleType == :Red
#             for e in Graphs.edges(geometry.graph)
#                 bond = (Graphs.src(e), Graphs.dst(e))
#                 if isKitaevZ(geometry, bond) && isKekuleRed(geometry, bond)
#                     push!(positions, bond[1])
#                     push!(positions, bond[2])
#                 end
#             end
#         elseif kekuleType == :Green
#             for e in Graphs.edges(geometry.graph)
#                 bond = (Graphs.src(e), Graphs.dst(e))
#                 if isKitaevZ(geometry, bond) && isKekuleGreen(geometry, bond)
#                     push!(positions, bond[1])
#                     push!(positions, bond[2])
#                 end
#             end
#         elseif kekuleType == :Blue
#             for e in Graphs.edges(geometry.graph)
#                 bond = (Graphs.src(e), Graphs.dst(e))
#                 if isKitaevZ(geometry, bond) && isKekuleBlue(geometry, bond)
#                     push!(positions, bond[1])
#                     push!(positions, bond[2])
#                 end
#             end
#         end
#     end
#     return reshape(positions, 2, length(positions) ÷ 2)
# end





function random_qubit(geometry::HoneycombGeometry)
    return rand(1:nv(geometry.graph))
end

function subsystems(geometry::HoneycombGeometry{Periodic}, n::Integer=2; cutType=:Z)
    if cutType == :Z
        sites = loops(geometry; kitaevTypes=(:X, :Y))
    elseif cutType == :X
        sites = loops(geometry; kitaevTypes=(:Y, :Z))
    elseif cutType == :Y
        sites = loops(geometry; kitaevTypes=(:X, :Z))
    end
    size(sites, 2) % n == 0 || throw(ArgumentError("n=$n sub systems not possible."))
    loops_per_subsystem = size(sites, 2) ÷ n
    return reshape(sites, loops_per_subsystem * size(sites, 1), n)
end

function subsystem(geometry::HoneycombGeometry{Periodic}, l::Integer; cutType=:Z)
    if cutType == :Z
        sites = loops(geometry; kitaevTypes=(:X, :Y))
    elseif cutType == :X
        sites = loops(geometry; kitaevTypes=(:Y, :Z))
    elseif cutType == :Y
        sites = loops(geometry; kitaevTypes=(:X, :Z))
    end
    sub = @view sites[:, 1:l]
    return reshape(sub, length(sub), 1)
end


struct KitaevXBondsIter{T<:HoneycombGeometry}
    edgIter::Graphs.SimpleGraphs.SimpleEdgeIter{SimpleGraph{Int64}}
    geometry::T
    function KitaevXBondsIter(geometry::T) where {T<:HoneycombGeometry}
        return new{T}(Graphs.edges(geometry.graph), geometry)
    end
end
function kitaevX_bonds(geometry::HoneycombGeometry)
    return KitaevXBondsIter(geometry)
end
function Base.iterate(b::KitaevXBondsIter)
    res = iterate(b.edgIter)
    isnothing(res) && return nothing
    e, st = res
    s, d = src(e), dst(e)
    if isKitaevX(b.geometry, (s, d))
        return ((s, d), st)
    else
        return iterate(b, st)
    end
end
function Base.iterate(b::KitaevXBondsIter, st)
    res = iterate(b.edgIter, st)
    isnothing(res) && return nothing
    e, st = res
    s, d = src(e), dst(e)
    if isKitaevX(b.geometry, (s, d))
        return ((s, d), st)
    else
        return iterate(b, st)
    end
end
Base.IteratorEltype(::Type{<:KitaevXBondsIter}) = Base.HasEltype()
Base.eltype(::Type{<:KitaevXBondsIter}) = Tuple{Int64,Int64}
Base.IteratorSize(::Type{<:KitaevXBondsIter}) = Base.SizeUnknown()
Base.show(io::IO, ::MIME"text/plain", b::KitaevXBondsIter) = print(io, "KitaevXBondsIter for $(typeof(b.geometry))")


struct KitaevYBondsIter{T<:HoneycombGeometry}
    edgIter::Graphs.SimpleGraphs.SimpleEdgeIter{SimpleGraph{Int64}}
    geometry::T
    function KitaevYBondsIter(geometry::T) where {T<:HoneycombGeometry}
        return new{T}(Graphs.edges(geometry.graph), geometry)
    end
end
function kitaevY_bonds(geometry::HoneycombGeometry)
    return KitaevYBondsIter(geometry)
end
function Base.iterate(b::KitaevYBondsIter)
    res = iterate(b.edgIter)
    isnothing(res) && return nothing
    e, st = res
    s, d = src(e), dst(e)
    if isKitaevY(b.geometry, (s, d))
        return ((s, d), st)
    else
        return iterate(b, st)
    end
end
function Base.iterate(b::KitaevYBondsIter, st)
    res = iterate(b.edgIter, st)
    isnothing(res) && return nothing
    e, st = res
    s, d = src(e), dst(e)
    if isKitaevY(b.geometry, (s, d))
        return ((s, d), st)
    else
        return iterate(b, st)
    end
end
Base.IteratorEltype(::Type{<:KitaevYBondsIter}) = Base.HasEltype()
Base.eltype(::Type{<:KitaevYBondsIter}) = Tuple{Int64,Int64}
Base.IteratorSize(::Type{<:KitaevYBondsIter}) = Base.SizeUnknown()
Base.show(io::IO, ::MIME"text/plain", b::KitaevYBondsIter) = print(io, "KitaevYBondsIter for $(typeof(b.geometry))")


struct KitaevZBondsIter{T<:HoneycombGeometry}
    edgIter::Graphs.SimpleGraphs.SimpleEdgeIter{SimpleGraph{Int64}}
    geometry::T
    function KitaevZBondsIter(geometry::T) where {T<:HoneycombGeometry}
        return new{T}(Graphs.edges(geometry.graph), geometry)
    end
end
function kitaevZ_bonds(geometry::HoneycombGeometry)
    return KitaevZBondsIter(geometry)
end
function Base.iterate(b::KitaevZBondsIter)
    res = iterate(b.edgIter)
    isnothing(res) && return nothing
    e, st = res
    s, d = src(e), dst(e)
    if isKitaevZ(b.geometry, (s, d))
        return ((s, d), st)
    else
        return iterate(b, st)
    end
end
function Base.iterate(b::KitaevZBondsIter, st)
    res = iterate(b.edgIter, st)
    isnothing(res) && return nothing
    e, st = res
    s, d = src(e), dst(e)
    if isKitaevZ(b.geometry, (s, d))
        return ((s, d), st)
    else
        return iterate(b, st)
    end
end
Base.IteratorEltype(::Type{<:KitaevZBondsIter}) = Base.HasEltype()
Base.eltype(::Type{<:KitaevZBondsIter}) = Tuple{Int64,Int64}
Base.IteratorSize(::Type{<:KitaevZBondsIter}) = Base.SizeUnknown()
Base.show(io::IO, ::MIME"text/plain", b::KitaevZBondsIter) = print(io, "KitaevZBondsIter for $(typeof(b.geometry))")


struct KekuleRedBondsIter{T<:HoneycombGeometry}
    edgIter::Graphs.SimpleGraphs.SimpleEdgeIter{SimpleGraph{Int64}}
    geometry::T
    function KekuleRedBondsIter(geometry::T) where {T<:HoneycombGeometry}
        return new{T}(Graphs.edges(geometry.graph), geometry)
    end
end
function kekuleRed_bonds(geometry::HoneycombGeometry)
    return KekuleRedBondsIter(geometry)
end
function Base.iterate(b::KekuleRedBondsIter)
    res = iterate(b.edgIter)
    isnothing(res) && return nothing
    e, st = res
    s, d = src(e), dst(e)
    if isKekuleRed(b.geometry, (s, d))
        return ((s, d), st)
    else
        return iterate(b, st)
    end
end
function Base.iterate(b::KekuleRedBondsIter, st)
    res = iterate(b.edgIter, st)
    isnothing(res) && return nothing
    e, st = res
    s, d = src(e), dst(e)
    if isKekuleRed(b.geometry, (s, d))
        return ((s, d), st)
    else
        return iterate(b, st)
    end
end
Base.IteratorEltype(::Type{<:KekuleRedBondsIter}) = Base.HasEltype()
Base.eltype(::Type{<:KekuleRedBondsIter}) = Tuple{Int64,Int64}
Base.IteratorSize(::Type{<:KekuleRedBondsIter}) = Base.SizeUnknown()
Base.show(io::IO, ::MIME"text/plain", b::KekuleRedBondsIter) = print(io, "KekuleRedBondsIter for $(typeof(b.geometry))")

struct KekuleGreenBondsIter{T<:HoneycombGeometry}
    edgIter::Graphs.SimpleGraphs.SimpleEdgeIter{SimpleGraph{Int64}}
    geometry::T
    function KekuleGreenBondsIter(geometry::T) where {T<:HoneycombGeometry}
        return new{T}(Graphs.edges(geometry.graph), geometry)
    end
end
function kekuleGreen_bonds(geometry::HoneycombGeometry)
    return KekuleGreenBondsIter(geometry)
end
function Base.iterate(b::KekuleGreenBondsIter)
    res = iterate(b.edgIter)
    isnothing(res) && return nothing
    e, st = res
    s, d = src(e), dst(e)
    if isKekuleGreen(b.geometry, (s, d))
        return ((s, d), st)
    else
        return iterate(b, st)
    end
end
function Base.iterate(b::KekuleGreenBondsIter, st)
    res = iterate(b.edgIter, st)
    isnothing(res) && return nothing
    e, st = res
    s, d = src(e), dst(e)
    if isKekuleGreen(b.geometry, (s, d))
        return ((s, d), st)
    else
        return iterate(b, st)
    end
end
Base.IteratorEltype(::Type{<:KekuleGreenBondsIter}) = Base.HasEltype()
Base.eltype(::Type{<:KekuleGreenBondsIter}) = Tuple{Int64,Int64}
Base.IteratorSize(::Type{<:KekuleGreenBondsIter}) = Base.SizeUnknown()
Base.show(io::IO, ::MIME"text/plain", b::KekuleGreenBondsIter) = print(io, "KekuleGreenBondsIter for $(typeof(b.geometry))")

struct KekuleBlueBondsIter{T<:HoneycombGeometry}
    edgIter::Graphs.SimpleGraphs.SimpleEdgeIter{SimpleGraph{Int64}}
    geometry::T
    function KekuleBlueBondsIter(geometry::T) where {T<:HoneycombGeometry}
        return new{T}(Graphs.edges(geometry.graph), geometry)
    end
end
function kekuleBlue_bonds(geometry::HoneycombGeometry)
    return KekuleBlueBondsIter(geometry)
end
function Base.iterate(b::KekuleBlueBondsIter)
    res = iterate(b.edgIter)
    isnothing(res) && return nothing
    e, st = res
    s, d = src(e), dst(e)
    if isKekuleBlue(b.geometry, (s, d))
        return ((s, d), st)
    else
        return iterate(b, st)
    end
end
function Base.iterate(b::KekuleBlueBondsIter, st)
    res = iterate(b.edgIter, st)
    isnothing(res) && return nothing
    e, st = res
    s, d = src(e), dst(e)
    if isKekuleBlue(b.geometry, (s, d))
        return ((s, d), st)
    else
        return iterate(b, st)
    end
end
Base.IteratorEltype(::Type{<:KekuleBlueBondsIter}) = Base.HasEltype()
Base.eltype(::Type{<:KekuleBlueBondsIter}) = Tuple{Int64,Int64}
Base.IteratorSize(::Type{<:KekuleBlueBondsIter}) = Base.SizeUnknown()
Base.show(io::IO, ::MIME"text/plain", b::KekuleBlueBondsIter) = print(io, "KekuleBlueBondsIter for $(typeof(b.geometry))")



struct HoneycombGeometryPlaquettesIter
    geometry::HoneycombGeometry{Periodic}
    ks::UnitRange{Int64}
    js::StepRange{Int64, Int64}
    order::NTuple{3,Symbol}
    function HoneycombGeometryPlaquettesIter(geometry::HoneycombGeometry{Periodic},
        order::NTuple{3,Symbol}=(:Z, :X, :Y))
        if order[1] == order[2] || order[2] == order[3] || order[1] == order[3]
            throw(ArgumentError("Invalid order: $order. The order must be chosen to walk along the plaquette in a cyclic manner."))
        end
        return new(geometry, 1:geometry.sizeY, 1:2:geometry.sizeX, order)
    end
end
function plaquettes(geometry::HoneycombGeometry{Periodic},
    order::Vararg{Symbol,3})
    return HoneycombGeometryPlaquettesIter(geometry, order)
end
function plaquettes(geometry::HoneycombGeometry{Periodic})
    return HoneycombGeometryPlaquettesIter(geometry)
end
function plaquettes(geometry::HoneycombGeometry{Periodic},
    order::NTuple{3,Symbol})
    return HoneycombGeometryPlaquettesIter(geometry, order)
end
function Base.iterate(b::HoneycombGeometryPlaquettesIter)
    j,k = first(b.js), first(b.ks)
    s1 = to_linear(b.geometry, (j, k))
    s2 = neighbor(b.geometry, s1, b.order[1])
    s3 = neighbor(b.geometry, s2, b.order[2])
    s4 = neighbor(b.geometry, s3, b.order[3])
    s5 = neighbor(b.geometry, s4, b.order[1])
    s6 = neighbor(b.geometry, s5, b.order[2])

    return ((s1, s2, s3, s4, s5, s6), (1, 1))
end
function Base.iterate(b::HoneycombGeometryPlaquettesIter, (j_idx, k_idx))
    if j_idx == length(b.js)
        if k_idx == length(b.ks)
            return nothing
        end
        j_idx = 1
        k_idx += 1
    else
        j_idx += 1
    end
    (j,k) = (b.js[j_idx], b.ks[k_idx])

    s1 = to_linear(b.geometry, (j, k))
    s2 = neighbor(b.geometry, s1, b.order[1])
    s3 = neighbor(b.geometry, s2, b.order[2])
    s4 = neighbor(b.geometry, s3, b.order[3])
    s5 = neighbor(b.geometry, s4, b.order[1])
    s6 = neighbor(b.geometry, s5, b.order[2])

    return ((s1, s2, s3, s4, s5, s6), (j_idx, k_idx))
end
Base.IteratorEltype(::Type{HoneycombGeometryPlaquettesIter}) = Base.HasEltype()
Base.eltype(::Type{HoneycombGeometryPlaquettesIter}) = NTuple{6,Int64}
Base.IteratorSize(::Type{HoneycombGeometryPlaquettesIter}) = Base.HasLength()
Base.length(b::HoneycombGeometryPlaquettesIter) = length(b.ks) * length(b.js)
Base.show(io::IO, ::MIME"text/plain", b::HoneycombGeometryPlaquettesIter) = print(io, "HoneycombGeometryPlaquettesIter for $(typeof(b.geometry))")


# function loops(geometry::HoneycombGeometry{Periodic}; kitaevTypes=(:X, :Y))
#     kitaevTypes[1] != kitaevTypes[2] || throw(ArgumentError("The Kitaev types can not be the same"))
#     geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
#     geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
#     loops = Int64[]
#     sizeX = geometry.sizeX
#     sizeY = geometry.sizeY
#     if kitaevTypes == (:X, :Y)
#         for j in 1:sizeY
#             n = (j - 1) * sizeX + 1
#             push!(loops, n)
#             for i in 1:sizeX-1
#                 if isodd(i)
#                     n = kitaevX_neighbor(geometry, n)
#                     push!(loops, n)
#                 else
#                     n = kitaevY_neighbor(geometry, n)
#                     push!(loops, n)
#                 end
#             end
#         end
#         return reshape(loops, sizeX, sizeY)
#     elseif kitaevTypes == (:Y, :X)
#         for j in 1:sizeY
#             n = (j - 1) * sizeX + 1
#             push!(loops, n)
#             for i in 1:sizeX-1
#                 if isodd(i)
#                     n = kitaevY_neighbor(geometry, n)
#                     push!(loops, n)
#                 else
#                     n = kitaevX_neighbor(geometry, n)
#                     push!(loops, n)
#                 end
#             end
#         end
#         return reshape(loops, sizeX, sizeY)
#     elseif kitaevTypes == (:X, :Z)
#         for j in 1:2:sizeX
#             n = j
#             push!(loops, n)
#             for i in 1:2sizeY-1
#                 if isodd(i)
#                     n = kitaevX_neighbor(geometry, n)
#                     push!(loops, n)
#                 else
#                     n = kitaevZ_neighbor(geometry, n)
#                     push!(loops, n)
#                 end
#             end
#         end
#         return reshape(loops, 2sizeY, sizeX ÷ 2)
#     elseif kitaevTypes == (:Z, :X)
#         for j in 1:2:sizeX
#             n = j
#             push!(loops, n)
#             for i in 1:2sizeY-1
#                 if isodd(i)
#                     n = kitaevZ_neighbor(geometry, n)
#                     push!(loops, n)
#                 else
#                     n = kitaevX_neighbor(geometry, n)
#                     push!(loops, n)
#                 end
#             end
#         end
#         return reshape(loops, 2sizeY, sizeX ÷ 2)
#     elseif kitaevTypes == (:Y, :Z)
#         for j in 1:2:sizeX
#             n = j
#             push!(loops, n)
#             for i in 1:2sizeY-1
#                 if isodd(i)
#                     n = kitaevY_neighbor(geometry, n)
#                     push!(loops, n)
#                 else
#                     n = kitaevZ_neighbor(geometry, n)
#                     push!(loops, n)
#                 end
#             end
#         end
#         return reshape(loops, 2sizeY, sizeX ÷ 2)
#     elseif kitaevTypes == (:Z, :Y)
#         for j in 1:2:sizeX
#             n = j
#             push!(loops, n)
#             for i in 1:2sizeY-1
#                 if isodd(i)
#                     n = kitaevZ_neighbor(geometry, n)
#                     push!(loops, n)
#                 else
#                     n = kitaevY_neighbor(geometry, n)
#                     push!(loops, n)
#                 end
#             end
#         end
#         return reshape(loops, 2sizeY, sizeX ÷ 2)
#     end
# end

struct HoneycombGeometryLoopsIter{L} # L: loop length
    geometry::HoneycombGeometry{Periodic}
    js::StepRange{Int64, Int64}
    is::StepRange{Int64, Int64}
    types::NTuple{2,Symbol}
    function HoneycombGeometryLoopsIter(geometry::HoneycombGeometry{Periodic},
        types::Tuple{Symbol,Symbol}=(:X, :Y))
        if length(unique(types)) != 2
            throw(ArgumentError("Invalid types: $types. Types can not be identical."))
        end
        if types[1] == :X && types[2] == :Y || types[1] == :Y && types[2] == :X
            js = 1:geometry.sizeY
            is = 1:1:geometry.sizeX-1
            L = length(is) + 1
            return new{L}(geometry, js, is, types)
        elseif types[1] == :X && types[2] == :Z || types[1] == :Z && types[2] == :X ||
            types[1] == :Y && types[2] == :Z || types[1] == :Z && types[2] == :Y
            js = 1:2:geometry.sizeX
            is = 1:1:2geometry.sizeY-1
            L = length(is) + 1
            return new{L}(geometry, js, is, types)
        end
    end
end
function loops(geometry::HoneycombGeometry{Periodic},
    types::Vararg{Symbol,2})
    return HoneycombGeometryLoopsIter(geometry, types)
end
function loops(geometry::HoneycombGeometry{Periodic})
    return HoneycombGeometryLoopsIter(geometry)
end
function loops(geometry::HoneycombGeometry{Periodic},
    types::NTuple{2,Symbol})
    return HoneycombGeometryLoopsIter(geometry, types)
end
function iteration_helper(g, prev, idx, types, first)
    if first == true
        return prev,false
    end
    if isodd(idx)
        return neighbor(g, prev, types[1]),false
    else
        return neighbor(g, prev, types[2]),false
    end
end
function Base.iterate(b::HoneycombGeometryLoopsIter)
    prev = 1
    first = true
    value = Tuple(((i -> ((prev,first) = iteration_helper(b.geometry, prev, i, b.types, first); prev))(k) for k in b.is))
    return (value, 1)
end
function Base.iterate(b::HoneycombGeometryLoopsIter, j_idx)
    if j_idx == length(b.js)
        return nothing
    end
    j = b.js[j_idx+1]
    if b.types[1] == :X && b.types[2] == :Y || b.types[1] == :Y && b.types[2] == :X
        prev = (j - 1) * b.geometry.sizeX + 1
    elseif b.types[1] == :X && b.types[2] == :Z || b.types[1] == :Z && b.types[2] == :X ||
        b.types[1] == :Y && b.types[2] == :Z || b.types[1] == :Z && b.types[2] == :Y
        prev = j
    end
    first = true

    value = Tuple(((i -> ((prev,first) = iteration_helper(b.geometry, prev, i, b.types, first); prev))(k) for k in b.is))
    return (value, 1)
end
Base.IteratorEltype(::Type{<:HoneycombGeometryLoopsIter}) = Base.HasEltype()
Base.eltype(::Type{HoneycombGeometryLoopsIter{L}}) where {L} = NTuple{L,Int64}
Base.IteratorSize(::Type{<:HoneycombGeometryLoopsIter}) = Base.HasLength()
Base.length(b::HoneycombGeometryLoopsIter) = length(b.js)
Base.show(io::IO, ::MIME"text/plain", b::HoneycombGeometryLoopsIter{L}) where {L} = print(io, "HoneycombGeometryLoopsIter with loop length $L")
