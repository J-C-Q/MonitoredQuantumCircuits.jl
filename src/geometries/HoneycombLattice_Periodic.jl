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
struct HoneycombGeometry{T<:BoundaryCondition,L1,L2} <: Geometry
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
    XYlooplength::L1
    XZlooplength::L2
    YZlooplength::L2
    # not type stable (since L1 and L2 are dynamic), but I guess it does not matter
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
        loops = collectLoops(HoneycombGeometry{Periodic}, graph, sizes)
        L1 = Val(size(loops[1],1))
        L2 = Val(size(loops[2],1))
        return new{Periodic,typeof(L1),typeof(L2)}(
            graph, sizeX, sizeY,
            collectBonds(HoneycombGeometry{Periodic}, graph, sizes)...,
            collectPlaquettes(HoneycombGeometry{Periodic}, graph, sizes),
            loops...,
            L1, L2, L2)
    end
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

function collectBonds(::Type{HoneycombGeometry{Periodic}}, graph::Graph, (sizeX,sizeY)::Tuple{Int64,Int64})
    bonds = Vector{Bond{Int64}}(undef, ne(graph))
    kitaevX_bonds = Bond{Int64}[]
    kitaevY_bonds = Bond{Int64}[]
    kitaevZ_bonds = Bond{Int64}[]
    kekuleRed_bonds = Bond{Int64}[]
    kekuleGreen_bonds = Bond{Int64}[]
    kekuleBlue_bonds = Bond{Int64}[]

    for (i,e) in enumerate(edges(graph))
        src, dst = Graphs.src(e), Graphs.dst(e)
        bond = Bond(src, dst)
        bonds[i] = bond
        if isKitaevX((sizeX,sizeY), bond)
            push!(kitaevX_bonds, bond)
        elseif isKitaevY((sizeX,sizeY), bond)
            push!(kitaevY_bonds, bond)
        elseif isKitaevZ((sizeX,sizeY), bond)
            push!(kitaevZ_bonds, bond)
        end
        if isKekuleRed((sizeX,sizeY), bond)
            push!(kekuleRed_bonds, bond)
        elseif isKekuleGreen((sizeX,sizeY), bond)
            push!(kekuleGreen_bonds, bond)
        elseif isKekuleBlue((sizeX,sizeY), bond)
            push!(kekuleBlue_bonds, bond)
        end
    end

    return bonds,
    kitaevX_bonds,
    kitaevY_bonds,
    kitaevZ_bonds,
    kekuleRed_bonds,
    kekuleGreen_bonds,
    kekuleBlue_bonds
end

function collectPlaquettes(::Type{HoneycombGeometry{Periodic}}, graph::Graph, (sizeX,sizeY)::Tuple{Int64,Int64})

    cyc = Matrix{Int64}(undef, 6, sizeY*div(sizeX, 2))
    i = 1
    for k in 1:sizeY
        for j in 1:2:sizeX
            m = to_linear((sizeX,sizeY), (j, k))
            cyc[1, i] = m
            m = kitaevZ_neighbor((sizeX,sizeY), m)
            cyc[2, i] = m
            m = kitaevX_neighbor((sizeX,sizeY), m)
            cyc[3, i] = m
            m = kitaevY_neighbor((sizeX,sizeY), m)
            cyc[4, i] = m
            m = kitaevZ_neighbor((sizeX,sizeY), m)
            cyc[5, i] = m
            m = kitaevX_neighbor((sizeX,sizeY), m)
            cyc[6, i] = m
            i += 1
        end
    end
    return cyc
end

function collectLoops(::Type{HoneycombGeometry{Periodic}}, graph::Graph, (sizeX,sizeY)::Tuple{Int64,Int64})
    loopsXY = Int64[]
    loopsXZ = Int64[]
    loopsYZ = Int64[]
    for j in 1:sizeY
        n = (j - 1) * sizeX + 1
        push!(loopsXY, n)
        for i in 1:sizeX-1
            if isodd(i)
                n = kitaevX_neighbor((sizeX,sizeY), n)
                push!(loopsXY, n)
            else
                n = kitaevY_neighbor((sizeX,sizeY), n)
                push!(loopsXY, n)
            end
        end
    end
    for j in 1:2:sizeX
        n = j
        push!(loopsXZ, n)
        for i in 1:2sizeY-1
            if isodd(i)
                n = kitaevX_neighbor((sizeX,sizeY), n)
                push!(loopsXZ, n)
            else
                n = kitaevZ_neighbor((sizeX,sizeY), n)
                push!(loopsXZ, n)
            end
        end
    end
    for j in 1:2:sizeX
        n = j
        push!(loopsYZ, n)
        for i in 1:2sizeY-1
            if isodd(i)
                n = kitaevY_neighbor((sizeX,sizeY), n)
                push!(loopsYZ, n)
            else
                n = kitaevZ_neighbor((sizeX,sizeY), n)
                push!(loopsYZ, n)
            end
        end
    end
    return reshape(loopsXY, sizeX, sizeY),
    reshape(loopsXZ, 2sizeY, sizeX ÷ 2),
    reshape(loopsYZ, 2sizeY, sizeX ÷ 2)
end

function isKitaevX((sizeX,sizeY)::Tuple{Int64,Int64}, bond::Bond)
    neighbor1 = kitaevX_neighbor((sizeX,sizeY), bond.qubit1)
    neighbor2 = kitaevX_neighbor((sizeX,sizeY), bond.qubit2)
    if Bond(neighbor1, neighbor2) == bond
        return true
    end
    return false
end
function isKitaevY((sizeX,sizeY)::Tuple{Int64,Int64}, bond::Bond)
    neighbor1 = kitaevY_neighbor((sizeX,sizeY), bond.qubit1)
    neighbor2 = kitaevY_neighbor((sizeX,sizeY), bond.qubit2)
    if Bond(neighbor1, neighbor2) == bond
        return true
    end
    return false
end
function isKitaevZ((sizeX,sizeY)::Tuple{Int64,Int64}, bond::Bond)
    neighbor1 = kitaevZ_neighbor((sizeX,sizeY), bond.qubit1)
    neighbor2 = kitaevZ_neighbor((sizeX,sizeY), bond.qubit2)
    if Bond(neighbor1, neighbor2) == bond
        return true
    end
    return false
end
function isKekuleRed((sizeX,sizeY)::Tuple{Int64,Int64}, bond::Bond)
    neighbor1 = kekuleRed_neighbor((sizeX,sizeY), bond.qubit1)
    neighbor2 = kekuleRed_neighbor((sizeX,sizeY), bond.qubit2)
    if Bond(neighbor1, neighbor2) == bond
        return true
    end
    return false
end
function isKekuleGreen((sizeX,sizeY)::Tuple{Int64,Int64}, bond::Bond)
    neighbor1 = kekuleGreen_neighbor((sizeX,sizeY), bond.qubit1)
    neighbor2 = kekuleGreen_neighbor((sizeX,sizeY), bond.qubit2)
    if Bond(neighbor1, neighbor2) == bond
        return true
    end
    return false
end
function isKekuleBlue((sizeX,sizeY)::Tuple{Int64,Int64}, bond::Bond)
    neighbor1 = kekuleBlue_neighbor((sizeX,sizeY), bond.qubit1)
    neighbor2 = kekuleBlue_neighbor((sizeX,sizeY), bond.qubit2)
    if Bond(neighbor1, neighbor2) == bond
        return true
    end
    return false
end
function kitaevX_neighbor((sizeX,sizeY)::Tuple{Int64,Int64}, site::Integer)
    i, j = to_grid((sizeX,sizeY), site)
    if isodd(i)
        return to_linear((sizeX,sizeY), (i + 1, j))
    else
        return to_linear((sizeX,sizeY),(i - 1, j))
    end
end
function kitaevY_neighbor((sizeX,sizeY)::Tuple{Int64,Int64}, site::Integer)
    i, j = to_grid((sizeX,sizeY), site)
    if iseven(i)
        return to_linear((sizeX,sizeY), (i + 1, j))
    else
        return to_linear((sizeX,sizeY), (i - 1, j))
    end
end
function kitaevZ_neighbor((sizeX,sizeY)::Tuple{Int64,Int64}, site::Integer)
    i, j = to_grid((sizeX,sizeY), site)
    if iseven(i)
        return to_linear((sizeX,sizeY), (i - 1, j + 1))
    else
        return to_linear((sizeX,sizeY), (i + 1, j - 1))
    end
end
function kekuleRed_neighbor((sizeX,sizeY)::Tuple{Int64,Int64}, site::Integer)
     i, j = to_grid((sizeX,sizeY), site)
    j = mod1(j, 3)
    if iseven(i)
        i = mod1(i, 6) ÷ 2
        if i == 1
            if j == 1
                return kitaevZ_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevY_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevX_neighbor((sizeX,sizeY), site)
            end
        elseif i == 2
            if j == 1
                return kitaevX_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevZ_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevY_neighbor((sizeX,sizeY), site)
            end
        elseif i == 3
            if j == 1
                return kitaevY_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevX_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevZ_neighbor((sizeX,sizeY), site)
            end
        end
    else
        i = mod1(i + 1, 6) ÷ 2
        if i == 1
            if j == 1
                return kitaevY_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevZ_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevX_neighbor((sizeX,sizeY), site)
            end
        elseif i == 2
            if j == 1
                return kitaevX_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevY_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevZ_neighbor((sizeX,sizeY), site)
            end
        elseif i == 3
            if j == 1
                return kitaevZ_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevX_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevY_neighbor((sizeX,sizeY), site)
            end
        end
    end
end
function kekuleGreen_neighbor((sizeX,sizeY)::Tuple{Int64,Int64}, site::Integer)
    i, j = to_grid((sizeX,sizeY), site)
    j = mod1(j, 3)
    if iseven(i)
        i = mod1(i, 6) ÷ 2
        if i == 1
            if j == 1
                return kitaevY_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevX_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevZ_neighbor((sizeX,sizeY), site)
            end
        elseif i == 2
            if j == 1
                return kitaevZ_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevY_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevX_neighbor((sizeX,sizeY), site)
            end
        elseif i == 3
            if j == 1
                return kitaevX_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevZ_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevY_neighbor((sizeX,sizeY), site)
            end
        end
    else
        i = mod1(i + 1, 6) ÷ 2
        if i == 1
            if j == 1
                return kitaevZ_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevX_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevY_neighbor((sizeX,sizeY), site)
            end
        elseif i == 2
            if j == 1
                return kitaevY_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevZ_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevX_neighbor((sizeX,sizeY), site)
            end
        elseif i == 3
            if j == 1
                return kitaevX_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevY_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevZ_neighbor((sizeX,sizeY), site)
            end
        end
    end
end
function kekuleBlue_neighbor((sizeX,sizeY)::Tuple{Int64,Int64}, site::Integer)
    i, j = to_grid((sizeX,sizeY), site)
    j = mod1(j, 3)
    if iseven(i)
        i = mod1(i, 6) ÷ 2
        if i == 1
            if j == 1
                return kitaevX_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevZ_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevY_neighbor((sizeX,sizeY), site)
            end
        elseif i == 2
            if j == 1
                return kitaevY_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevX_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevZ_neighbor((sizeX,sizeY), site)
            end
        elseif i == 3
            if j == 1
                return kitaevZ_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevY_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevX_neighbor((sizeX,sizeY), site)
            end
        end
    else
        i = mod1(i + 1, 6) ÷ 2
        if i == 1
            if j == 1
                return kitaevX_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevY_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevZ_neighbor((sizeX,sizeY), site)
            end
        elseif i == 2
            if j == 1
                return kitaevZ_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevX_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevY_neighbor((sizeX,sizeY), site)
            end
        elseif i == 3
            if j == 1
                return kitaevY_neighbor((sizeX,sizeY), site)
            elseif j == 2
                return kitaevZ_neighbor((sizeX,sizeY), site)
            elseif j == 3
                return kitaevX_neighbor((sizeX,sizeY), site)
            end
        end
    end
end

function isKitaevX(geometry::HoneycombGeometry{Periodic}, bond::Bond)
    return isKitaevX((geometry.sizeX, geometry.sizeY), bond)
end
function isKitaevY(geometry::HoneycombGeometry{Periodic}, bond::Bond)
    return isKitaevY((geometry.sizeX, geometry.sizeY), bond)
end
function isKitaevZ(geometry::HoneycombGeometry{Periodic}, bond::Bond)
    return isKitaevZ((geometry.sizeX, geometry.sizeY), bond)
end
function isKekuleRed(geometry::HoneycombGeometry{Periodic}, bond::Bond)
    return isKekuleRed((geometry.sizeX, geometry.sizeY), bond)
end
function isKekuleGreen(geometry::HoneycombGeometry{Periodic}, bond::Bond)
    return isKekuleGreen((geometry.sizeX, geometry.sizeY), bond)
end
function isKekuleBlue(geometry::HoneycombGeometry{Periodic}, bond::Bond)
    return isKekuleBlue((geometry.sizeX, geometry.sizeY), bond)
end
function kitaevX_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    return kitaevX_neighbor((geometry.sizeX, geometry.sizeY), site)
end
function kitaevY_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    return kitaevY_neighbor((geometry.sizeX, geometry.sizeY), site)
end
function kitaevZ_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    return kitaevZ_neighbor((geometry.sizeX, geometry.sizeY), site)
end
function kekuleRed_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    return kekuleRed_neighbor((geometry.sizeX, geometry.sizeY), site)
end
function kekuleGreen_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    return kekuleGreen_neighbor((geometry.sizeX, geometry.sizeY), site)
end
function kekuleBlue_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    return kekuleBlue_neighbor((geometry.sizeX, geometry.sizeY), site)
end

function random_bond(geometry::HoneycombGeometry{Periodic})
    return rand(geometry.bonds)
end
function random_kitaevX_bond(geometry::HoneycombGeometry{Periodic})
    return rand(geometry.kitaevX_bonds)
end
function random_kitaevY_bond(geometry::HoneycombGeometry{Periodic})
    return rand(geometry.kitaevY_bonds)
end
function random_kitaevZ_bond(geometry::HoneycombGeometry{Periodic})
    return rand(geometry.kitaevZ_bonds)
end
function random_kekuleRed_bond(geometry::HoneycombGeometry{Periodic})
    return rand(geometry.kekuleRed_bonds)
end
function random_kekuleGreen_bond(geometry::HoneycombGeometry{Periodic})
    return rand(geometry.kekuleGreen_bonds)
end
function random_kekuleBlue_bond(geometry::HoneycombGeometry{Periodic})
    return rand(geometry.kekuleBlue_bonds)
end

function bonds(geometry::HoneycombGeometry{Periodic})
    return geometry.bonds
end
function kitaevX_bonds(geometry::HoneycombGeometry{Periodic})
    return geometry.kitaevX_bonds
end
function kitaevY_bonds(geometry::HoneycombGeometry{Periodic})
    return geometry.kitaevY_bonds
end
function kitaevZ_bonds(geometry::HoneycombGeometry{Periodic})
    return geometry.kitaevZ_bonds
end
function kekuleRed_bonds(geometry::HoneycombGeometry{Periodic})
    return geometry.kekuleRed_bonds
end
function kekuleGreen_bonds(geometry::HoneycombGeometry{Periodic})
    return geometry.kekuleGreen_bonds
end
function kekuleBlue_bonds(geometry::HoneycombGeometry{Periodic})
    return geometry.kekuleBlue_bonds
end

function plaquettes(geometry::HoneycombGeometry{Periodic})
    return eachcol(geometry.plaquettes)
end
function loopsXZ(geometry::HoneycombGeometry{Periodic})
    return eachcol(geometry.loopsXZ)
end
function loopsXY(geometry::HoneycombGeometry{Periodic})
    return eachcol(geometry.loopsXY)
end
function loopsYZ(geometry::HoneycombGeometry{Periodic})
    return eachcol(geometry.loopsYZ)
end
function XZlooplength(geometry::HoneycombGeometry{Periodic})
    return geometry.XZlooplength
end
function XYlooplength(geometry::HoneycombGeometry{Periodic})
    return geometry.XYlooplength
end
function YZlooplength(geometry::HoneycombGeometry{Periodic})
    return geometry.YZlooplength
end




function subsystems(geometry::HoneycombGeometry{Periodic}, n::Integer=2; cutType=:Z)
    if cutType == :Z
        sites = loopsXY(geometry)
    elseif cutType == :X
        sites = loopsYZ(geometry)
    elseif cutType == :Y
        sites = loopsXZ(geometry)
    end
    length(sites) % n == 0 || throw(ArgumentError("n=$n sub systems not possible."))
    loops_per_subsystem = length(sites) ÷ n
    return reshape(sites.parent, loops_per_subsystem * length(sites[1]), n)
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

export HoneycombGeometry
export Periodic
export plaquettes
export loops
export bonds
export kitaevX_bonds
export kitaevY_bonds
export kitaevZ_bonds
export kekuleRed_bonds
export kekuleBlue_bonds
export kekuleGreen_bonds
export subsystems
export subsystem
export random_bond
export random_kitaevX_bond
export random_kitaevY_bond
export random_kitaevZ_bond
export random_kekuleRed_bond
export random_kekuleGreen_bond
export random_kekuleBlue_bond
export XYlooplength
export XZlooplength
export YZlooplength
export loopsXY
export loopsXZ
export loopsYZ
