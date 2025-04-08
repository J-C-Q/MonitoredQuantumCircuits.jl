"""
    HoneycombGeometry(sizeX::Integer, sizeY::Integer)

"""
struct HoneycombGeometry{T<:BoundaryCondition} <: Geometry
    graph::Graph
    sizeX::Int64
    sizeY::Int64

    # gridPositions::Vector{Tuple{Int64,Int64}} # the grid positions of the qubits
    function HoneycombGeometry(type::Type{Periodic}, sizeX::Integer, sizeY::Integer)
        sizeX = sizeX * 2
        sizeX > 0 || throw(ArgumentError("size must be positive"))
        sizeY > 0 || throw(ArgumentError("size must be positive"))
        sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
        graph = SimpleGraph(sizeX * sizeY)
        g = new{Periodic}(graph, sizeX, sizeY)
        for j in 1:sizeY
            for i in 1:2:sizeX
                add_edge!(graph, to_linear(g, (i, j)), to_linear(g, (i + 1, j)))
            end
        end
        for j in 1:sizeY
            for i in 2:2:sizeX
                add_edge!(graph, to_linear(g, (i, j)), to_linear(g, (i + 1, j)))
            end
        end
        for j in 1:sizeY
            for i in 2:2:sizeX
                add_edge!(graph, to_linear(g, (i, j)), to_linear(g, (i - 1, j + 1)))
            end
        end

        return g
    end
    function HoneycombGeometry(type::Type{Open}, sizeX::Integer, sizeY::Integer)
        sizeX = sizeX * 2
        sizeX > 0 || throw(ArgumentError("size must be positive"))
        sizeY > 0 || throw(ArgumentError("size must be positive"))
        sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
        graph = SimpleGraph(sizeX * sizeY)

        g = new{Open}(graph, sizeX, sizeY)

        for j in 1:sizeY
            for i in 1:2:sizeX
                add_edge!(graph, to_linear(g, (i, j)), to_linear(g, (i + 1, j)))
            end
        end
        for j in 1:sizeY
            for i in 2:2:sizeX
                add_edge!(graph, to_linear(g, (i, j)), to_linear(g, (i + 1, j)))
            end
        end
        for j in 1:sizeY
            for i in 2:2:sizeX
                add_edge!(graph, to_linear(g, (i, j)), to_linear(g, (i - 1, j + 1)))
            end
        end

        return g
    end
end

function visualize(io::IO, geometry::HoneycombGeometry{Periodic})
end

function to_linear(geometry::HoneycombGeometry{Periodic}, (i, j)::NTuple{2,Int64})
    return mod1(i, geometry.sizeX) + geometry.sizeX * (mod1(j, geometry.sizeY) - 1)
end

function to_grid(geometry::HoneycombGeometry{Periodic}, i::Int64)
    return (mod1(i, geometry.sizeX), div(i - 1, geometry.sizeX) + 1)
end


function neighbor(geometry::HoneycombGeometry{Periodic}, i::Int64; direction::Symbol)
    direction in [:X, :Y, :Z, :Red, :Greenm, :Blue] || throw(ArgumentError("Invalid direction: $direction"))
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


function kitaevX(geometry::HoneycombGeometry{Periodic})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    bonds = Tuple{Int64,Int64}[]
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    for j in 1:sizeY
        for i in 1:2:sizeX
            push!(bonds, (to_linear(g, (i, j)), to_linear(g, (i + 1, j))))
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
            push!(bonds, (to_linear(g, (i, j)), to_linear(g, (i + 1, j))))
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
            push!(bonds, (to_linear(g, (i, j)), to_linear(g, (i - 1, j + 1))))
        end
    end
    return bonds
end

function isKitaevX(geometry::HoneycombGeometry{Periodic}, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    neighbor1 = kitaevX_neighbor(geometry, bond[1])
    neighbor2 = kitaevX_neighbor(geometry, bond[2])
    if (neighbor2, neighbor1) == bond
        return true
    end
    return false
    return false
end

function isKitaevY(geometry::HoneycombGeometry{Periodic}, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    neighbor1 = kitaevY_neighbor(geometry, bond[1])
    neighbor2 = kitaevY_neighbor(geometry, bond[2])
    if (neighbor2, neighbor1) == bond
        return true
    end
    return false
    return false
end

function isKitaevZ(geometry::HoneycombGeometry{Periodic}, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    neighbor1 = kitaevZ_neighbor(geometry, bond[1])
    neighbor2 = kitaevZ_neighbor(geometry, bond[2])
    if (neighbor2, neighbor1) == bond
        return true
    end
    return false
end

function isKekuleRed(geometry::HoneycombGeometry{Periodic}, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    neighbor1 = kekuleRed_neighbor(geometry, bond[1])
    neighbor2 = kekuleRed_neighbor(geometry, bond[2])
    if (neighbor2, neighbor1) == bond
        return true
    end
    return false
end

function isKekuleGreen(geometry::HoneycombGeometry{Periodic}, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    neighbor1 = kekuleGreen_neighbor(geometry, bond[1])
    neighbor2 = kekuleGreen_neighbor(geometry, bond[2])
    if (neighbor2, neighbor1) == bond
        return true
    end
    return false
end

function isKekuleBlue(geometry::HoneycombGeometry{Periodic}, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    neighbor1 = kekuleBlue_neighbor(geometry, bond[1])
    neighbor2 = kekuleBlue_neighbor(geometry, bond[2])
    if (neighbor2, neighbor1) == bond
        return true
    end
    return false
end

function kitaevX_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    i, j = to_grid(geometry, site)
    if isodd(i)
        return to_linear(geometry, (i + 1, j))
    else
        return to_linear(geometry, (i - 1, j))
    end
end



function kitaevY_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    i, j = to_grid(geometry, site)
    if iseven(i)
        return to_linear(geometry, (i + 1, j))
    else
        return to_linear(geometry, (i - 1, j))
    end
end

function kitaevZ_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    i, j = to_grid(geometry, site)
    if iseven(i)
        return to_linear(geometry, (i - 1, j + 1))
    else
        return to_linear(geometry, (i + 1, j - 1))
    end
end


function kekuleRed_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
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

function bonds(geometry::HoneycombGeometry{Periodic}; kitaevType=:All, kekuleType=:All)
    positions = Int64[]
    if kitaevType == :All
        if kekuleType == :All
            for e in Graphs.edges(geometry.graph)
                push!(positions, Graphs.src(e))
                push!(positions, Graphs.dst(e))
            end
        elseif kekuleType == :Red
            for e in Graphs.edges(geometry.graph)
                bond = (Graphs.src(e), Graphs.dst(e))
                if isKekuleRed(geometry, bond)
                    push!(positions, bond[1])
                    push!(positions, bond[2])
                end
            end
        elseif kekuleType == :Green
            for e in Graphs.edges(geometry.graph)
                bond = (Graphs.src(e), Graphs.dst(e))
                if isKekuleGreen(geometry, bond)
                    push!(positions, bond[1])
                    push!(positions, bond[2])
                end
            end
        elseif kekuleType == :Blue
            for e in Graphs.edges(geometry.graph)
                bond = (Graphs.src(e), Graphs.dst(e))
                if isKekuleBlue(geometry, bond)
                    push!(positions, bond[1])
                    push!(positions, bond[2])
                end
            end
        end
    elseif kitaevType == :X
        if kekuleType == :All
            for e in Graphs.edges(geometry.graph)
                bond = (Graphs.src(e), Graphs.dst(e))
                if isKitaevX(geometry, bond)
                    push!(positions, Graphs.src(e))
                    push!(positions, Graphs.dst(e))
                end
            end
        elseif kekuleType == :Red
            for e in Graphs.edges(geometry.graph)
                bond = (Graphs.src(e), Graphs.dst(e))
                if isKitaevX(geometry, bond) && isKekuleRed(geometry, bond)
                    push!(positions, bond[1])
                    push!(positions, bond[2])
                end
            end
        elseif kekuleType == :Green
            for e in Graphs.edges(geometry.graph)
                bond = (Graphs.src(e), Graphs.dst(e))
                if isKitaevX(geometry, bond) && isKekuleGreen(geometry, bond)
                    push!(positions, bond[1])
                    push!(positions, bond[2])
                end
            end
        elseif kekuleType == :Blue
            for e in Graphs.edges(geometry.graph)
                bond = (Graphs.src(e), Graphs.dst(e))
                if isKitaevX(geometry, bond) && isKekuleBlue(geometry, bond)
                    push!(positions, bond[1])
                    push!(positions, bond[2])
                end
            end
        end
    elseif kitaevType == :Y
        if kekuleType == :All
            for e in Graphs.edges(geometry.graph)
                bond = (Graphs.src(e), Graphs.dst(e))
                if isKitaevY(geometry, bond)
                    push!(positions, Graphs.src(e))
                    push!(positions, Graphs.dst(e))
                end
            end
        elseif kekuleType == :Red
            for e in Graphs.edges(geometry.graph)
                bond = (Graphs.src(e), Graphs.dst(e))
                if isKitaevY(geometry, bond) && isKekuleRed(geometry, bond)
                    push!(positions, bond[1])
                    push!(positions, bond[2])
                end
            end
        elseif kekuleType == :Green
            for e in Graphs.edges(geometry.graph)
                bond = (Graphs.src(e), Graphs.dst(e))
                if isKitaevY(geometry, bond) && isKekuleGreen(geometry, bond)
                    push!(positions, bond[1])
                    push!(positions, bond[2])
                end
            end
        elseif kekuleType == :Blue
            for e in Graphs.edges(geometry.graph)
                bond = (Graphs.src(e), Graphs.dst(e))
                if isKitaevY(geometry, bond) && isKekuleBlue(geometry, bond)
                    push!(positions, bond[1])
                    push!(positions, bond[2])
                end
            end
        end
    elseif kitaevType == :Z
        if kekuleType == :All
            for e in Graphs.edges(geometry.graph)
                bond = (Graphs.src(e), Graphs.dst(e))
                if isKitaevZ(geometry, bond)
                    push!(positions, Graphs.src(e))
                    push!(positions, Graphs.dst(e))
                end
            end
        elseif kekuleType == :Red
            for e in Graphs.edges(geometry.graph)
                bond = (Graphs.src(e), Graphs.dst(e))
                if isKitaevZ(geometry, bond) && isKekuleRed(geometry, bond)
                    push!(positions, bond[1])
                    push!(positions, bond[2])
                end
            end
        elseif kekuleType == :Green
            for e in Graphs.edges(geometry.graph)
                bond = (Graphs.src(e), Graphs.dst(e))
                if isKitaevZ(geometry, bond) && isKekuleGreen(geometry, bond)
                    push!(positions, bond[1])
                    push!(positions, bond[2])
                end
            end
        elseif kekuleType == :Blue
            for e in Graphs.edges(geometry.graph)
                bond = (Graphs.src(e), Graphs.dst(e))
                if isKitaevZ(geometry, bond) && isKekuleBlue(geometry, bond)
                    push!(positions, bond[1])
                    push!(positions, bond[2])
                end
            end
        end
    end
    return reshape(positions, 2, length(positions) ÷ 2)
end

function plaquettes(geometry::HoneycombGeometry{Periodic})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    cyc = Matrix{Int64}(undef, 6, sizeY^2)
    i = 1
    for k in 1:sizeY
        for j in 1:2:sizeX
            m = to_linear(geometry, (j, k))
            cyc[1, i] = m
            m = kitaevZ_neighbor(geometry, m)
            cyc[2, i] = m
            m = kitaevX_neighbor(geometry, m)
            cyc[3, i] = m
            m = kitaevY_neighbor(geometry, m)
            cyc[4, i] = m
            m = kitaevZ_neighbor(geometry, m)
            cyc[5, i] = m
            m = kitaevX_neighbor(geometry, m)
            cyc[6, i] = m
            i += 1
        end
    end
    return cyc
end

function loops(geometry::HoneycombGeometry{Periodic}; kitaevTypes=(:X, :Y))
    kitaevTypes[1] != kitaevTypes[2] || throw(ArgumentError("The Kitaev types can not be the same"))
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    loops = Int64[]
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    if kitaevTypes == (:X, :Y)
        for j in 1:sizeY
            n = (j - 1) * sizeX + 1
            push!(loops, n)
            for i in 1:sizeX-1
                if isodd(i)
                    n = kitaevX_neighbor(geometry, n)
                    push!(loops, n)
                else
                    n = kitaevY_neighbor(geometry, n)
                    push!(loops, n)
                end
            end
        end
        return reshape(loops, sizeX, sizeY)
    elseif kitaevTypes == (:Y, :X)
        for j in 1:sizeY
            n = (j - 1) * sizeX + 1
            push!(loops, n)
            for i in 1:sizeX-1
                if isodd(i)
                    n = kitaevY_neighbor(geometry, n)
                    push!(loops, n)
                else
                    n = kitaevX_neighbor(geometry, n)
                    push!(loops, n)
                end
            end
        end
        return reshape(loops, sizeX, sizeY)
    elseif kitaevTypes == (:X, :Z)
        for j in 1:2:sizeX
            n = j
            push!(loops, n)
            for i in 1:2sizeY-1
                if isodd(i)
                    n = kitaevX_neighbor(geometry, n)
                    push!(loops, n)
                else
                    n = kitaevZ_neighbor(geometry, n)
                    push!(loops, n)
                end
            end
        end
        return reshape(loops, 2sizeY, sizeX ÷ 2)
    elseif kitaevTypes == (:Z, :X)
        for j in 1:2:sizeX
            n = j
            push!(loops, n)
            for i in 1:2sizeY-1
                if isodd(i)
                    n = kitaevZ_neighbor(geometry, n)
                    push!(loops, n)
                else
                    n = kitaevX_neighbor(geometry, n)
                    push!(loops, n)
                end
            end
        end
        return reshape(loops, 2sizeY, sizeX ÷ 2)
    elseif kitaevTypes == (:Y, :Z)
        for j in 1:2:sizeX
            n = j
            push!(loops, n)
            for i in 1:2sizeY-1
                if isodd(i)
                    n = kitaevY_neighbor(geometry, n)
                    push!(loops, n)
                else
                    n = kitaevZ_neighbor(geometry, n)
                    push!(loops, n)
                end
            end
        end
        return reshape(loops, 2sizeY, sizeX ÷ 2)
    elseif kitaevTypes == (:Z, :Y)
        for j in 1:2:sizeX
            n = j
            push!(loops, n)
            for i in 1:2sizeY-1
                if isodd(i)
                    n = kitaevZ_neighbor(geometry, n)
                    push!(loops, n)
                else
                    n = kitaevY_neighbor(geometry, n)
                    push!(loops, n)
                end
            end
        end
        return reshape(loops, 2sizeY, sizeX ÷ 2)
    end
end

function random_qubit(geometry::HoneycombGeometry{Periodic})
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
