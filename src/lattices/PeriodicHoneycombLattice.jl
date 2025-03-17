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

        for j in 1:sizeY
            for i in 1:2:sizeX
                add_edge!(graph, to_linear(i, j, sizeX, sizeY), to_linear(i + 1, j, sizeX, sizeY))
            end
        end
        for j in 1:sizeY
            for i in 2:2:sizeX
                add_edge!(graph, to_linear(i, j, sizeX, sizeY), to_linear(i + 1, j, sizeX, sizeY))
            end
        end
        for j in 1:sizeY
            for i in 2:2:sizeX
                add_edge!(graph, to_linear(i, j, sizeX, sizeY), to_linear(i - 1, j + 1, sizeX, sizeY))
            end
        end
        # gridPositions = [(i, j) for j in 1:sizeY for i in 1:sizeX]

        return new{Periodic}(graph, sizeX, sizeY)
    end
    function HoneycombGeometry(type::Type{Open}, sizeX::Integer, sizeY::Integer)
        sizeX = sizeX * 2
        sizeX > 0 || throw(ArgumentError("size must be positive"))
        sizeY > 0 || throw(ArgumentError("size must be positive"))
        sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
        graph = SimpleGraph(sizeX * sizeY)

        for j in 1:sizeY
            for i in 1:2:sizeX
                add_edge!(graph, to_linear(i, j, sizeX, sizeY), to_linear(i + 1, j, sizeX, sizeY))
            end
        end
        for j in 1:sizeY
            for i in 2:2:sizeX
                add_edge!(graph, to_linear(i, j, sizeX, sizeY), to_linear(i + 1, j, sizeX, sizeY))
            end
        end
        for j in 1:sizeY
            for i in 2:2:sizeX
                add_edge!(graph, to_linear(i, j, sizeX, sizeY), to_linear(i - 1, j + 1, sizeX, sizeY))
            end
        end

        return new{Open}(graph, sizeX, sizeY)
    end
end

function visualize(io::IO, geometry::HoneycombGeometry{Periodic})
end

function to_linear(i, j, sizeX, sizeY)
    return mod1(i, sizeX) + sizeX * (mod1(j, sizeY) - 1)
end

function to_grid(linear, sizeX, sizeY)
    return (mod1(linear, sizeX), div(linear - 1, sizeX) + 1)
end

function kitaevX(geometry::HoneycombGeometry{Periodic})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    bonds = Tuple{Int64,Int64}[]
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    for j in 1:sizeY
        for i in 1:2:sizeX
            push!(bonds, (to_linear(i, j, sizeX, sizeY), to_linear(i + 1, j, sizeX, sizeY)))
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
            push!(bonds, (to_linear(i, j, sizeX, sizeY), to_linear(i + 1, j, sizeX, sizeY)))
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
            push!(bonds, (to_linear(i, j, sizeX, sizeY), to_linear(i - 1, j + 1, sizeX, sizeY)))
        end
    end
    return bonds
end

function isKitaevX(geometry::HoneycombGeometry{Periodic}, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    i_x, i_y = to_grid(bond[1], sizeX, sizeY)
    j_x, j_y = to_grid(bond[2], sizeX, sizeY)

    xxs = kitaevX(geometry)
    if bond in xxs || (bond[2], bond[1]) in xxs
        return true
    end
    return false
end

function isKitaevY(geometry::HoneycombGeometry{Periodic}, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    i_x, i_y = to_grid(bond[1], sizeX, sizeY)
    j_x, j_y = to_grid(bond[2], sizeX, sizeY)

    yys = kitaevY(geometry)
    if bond in yys || (bond[2], bond[1]) in yys
        return true
    end
    return false
end

function isKitaevZ(geometry::HoneycombGeometry{Periodic}, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    i_x, i_y = to_grid(bond[1], sizeX, sizeY)
    j_x, j_y = to_grid(bond[2], sizeX, sizeY)


    zzs = kitaevZ(geometry)
    if bond in zzs || (bond[2], bond[1]) in zzs
        return true
    end
    return false
end

function kitaevType(geometry::HoneycombGeometry{Periodic}, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    if isKitaevX(geometry, bond)
        return :X
    elseif isKitaevY(geometry, bond)
        return :Y
    elseif isKitaevZ(geometry, bond)
        return :Z
    else
        return :none
    end
end

function isKitaev_(type::Symbol, geometry::HoneycombGeometry{Periodic}, bond::Tuple{Int64,Int64})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    if type == :X
        return isKitaevX(geometry, bond)
    elseif type == :Y
        return isKitaevY(geometry, bond)
    elseif type == :Z
        return isKitaevZ(geometry, bond)
    else
        return false
    end
end

function kitaev_neighbor(type::Symbol, geometry::HoneycombGeometry{Periodic}, site::Integer)
    if type == :X
        return kitaevX_neighbor(geometry, site)
    elseif type == :Y
        return kitaevY_neighbor(geometry, site)
    elseif type == :Z
        return kitaevZ_neighbor(geometry, site)
    end
    return nothing
end

function kitaevX_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    i, j = to_grid(site, geometry.sizeX, geometry.sizeY)
    if isodd(i)
        return to_linear(i + 1, j, geometry.sizeX, geometry.sizeY)
    else
        return to_linear(i - 1, j, geometry.sizeX, geometry.sizeY)
    end
end



function kitaevY_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    i, j = to_grid(site, geometry.sizeX, geometry.sizeY)
    if iseven(i)
        return to_linear(i + 1, j, geometry.sizeX, geometry.sizeY)
    else
        return to_linear(i - 1, j, geometry.sizeX, geometry.sizeY)
    end
end

function kitaevZ_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    i, j = to_grid(site, geometry.sizeX, geometry.sizeY)
    if iseven(i)
        return to_linear(i - 1, j + 1, geometry.sizeX, geometry.sizeY)
    else
        return to_linear(i + 1, j - 1, geometry.sizeX, geometry.sizeY)
    end
end


function kekuleRed_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    evenmatrix = [:Z :X :Y
        :Y :Z :X
        :X :Y :Z]
    oddmatrix = [:Y :X :Z
        :Z :Y :X
        :X :Z :Y]
    i, j = to_grid(site, geometry.sizeX, geometry.sizeY)
    j = mod1(j, 3)
    if iseven(i)
        i = mod1(i, 6) ÷ 2
        return kitaev_neighbor(evenmatrix[j, i], geometry, site)
    else
        i = mod1(i + 1, 6) ÷ 2
        return kitaev_neighbor(oddmatrix[j, i], geometry, site)
    end
end

function kekuleGreen_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    evenmatrix = [:Y :Z :X
        :X :Y :Z
        :Z :X :Y]
    oddmatrix = [:Z :Y :X
        :X :Z :Y
        :Y :X :Z]

    i, j = to_grid(site, geometry.sizeX, geometry.sizeY)
    j = mod1(j, 3)
    if iseven(i)
        i = mod1(i, 6) ÷ 2
        return kitaev_neighbor(evenmatrix[j, i], geometry, site)
    else
        i = mod1(i + 1, 6) ÷ 2
        return kitaev_neighbor(oddmatrix[j, i], geometry, site)
    end
end

function kekuleBlue_neighbor(geometry::HoneycombGeometry{Periodic}, site::Integer)
    evenmatrix = [:X :Y :Z
        :Z :X :Y
        :Y :Z :X]
    oddmatrix = [:X :Z :Y
        :Y :X :Z
        :Z :Y :X]

    i, j = to_grid(site, geometry.sizeX, geometry.sizeY)
    j = mod1(j, 3)
    if iseven(i)
        i = mod1(i, 6) ÷ 2
        return kitaev_neighbor(evenmatrix[j, i], geometry, site)
    else
        i = mod1(i + 1, 6) ÷ 2
        return kitaev_neighbor(oddmatrix[j, i], geometry, site)
    end
end

function plaquettes(geometry::HoneycombGeometry{Periodic})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    cyc = Matrix{Int64}(undef, sizeY^2, 6)
    i = 1
    for k in 1:sizeY
        for j in 1:2:sizeX
            m = to_linear(j, k, sizeX, sizeY)
            cyc[i, 1] = m
            m = kitaevZ_neighbor(geometry, m)
            cyc[i, 2] = m
            m = kitaevX_neighbor(geometry, m)
            cyc[i, 3] = m
            m = kitaevY_neighbor(geometry, m)
            cyc[i, 4] = m
            m = kitaevZ_neighbor(geometry, m)
            cyc[i, 5] = m
            m = kitaevX_neighbor(geometry, m)
            cyc[i, 6] = m
            i += 1
        end
    end
    collect(eachrow(cyc))
end
function long_cycles(geometry::HoneycombGeometry{Periodic})
    geometry.sizeX % 2 == 0 || throw(ArgumentError("The sizeX must be even"))
    geometry.sizeY % 2 == 0 || throw(ArgumentError("The sizeY must be even"))
    loop1 = Int64[1]
    loop2 = Int64[1]
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    n = 1
    for i in 1:sizeX-1
        if isodd(i)
            n = kitaevX_neighbor(geometry, n)
            push!(loop1, n)
        else
            n = kitaevY_neighbor(geometry, n)
            push!(loop1, n)
        end
    end
    n = 1
    for i in 1:2sizeX-1
        if isodd(i)
            n = kitaevZ_neighbor(geometry, n)
            push!(loop2, n)
        else
            n = kitaevY_neighbor(geometry, n)
            push!(loop2, n)
        end
    end
    return [loop1, loop2]
end

function random_qubit(geometry::HoneycombGeometry{Periodic})
    return rand(1:nv(geometry.graph))
end
