include("utils/cycles.jl")
"""
    PeriodicHoneycombGeometry(sizeX::Integer, sizeY::Integer)

Simmilar to the `HoneycombGeometry` but with periodic boundary conditions in both directions (i.e. on a torus).
"""
struct PeriodicHoneycombGeometry <: Geometry
    graph::Graph
    sizeX::Int64
    sizeY::Int64
    gridPositions::Vector{Tuple{Int64,Int64}} # the grid positions of the qubits
    function PeriodicHoneycombGeometry(sizeX::Integer, sizeY::Integer)
        sizeX = sizeX * 2
        @assert sizeX > 0 "size must be positive"
        @assert sizeY > 0 "size must be positive"
        @assert sizeY % 2 == 0 "The sizeY must be even"
        graph = SimpleGraph(sizeX * sizeY)
        # graph = grid([sizeX, sizeY]; periodic=true)

        # for j in 1:sizeY
        #     for i in (j%2+1+(j-1)*(sizeX)):2:j*(sizeX)
        #         rem_edge!(graph, mod1(i, sizeX * sizeY), mod1(i + sizeX, sizeX * sizeY))
        #     end
        # end

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
        gridPositions = [(i, j) for j in 1:sizeY for i in 1:sizeX]

        return new(graph, sizeX, sizeY, gridPositions)
    end
end

function visualize(io::IO, geometry::PeriodicHoneycombGeometry)
end

function to_linear(i, j, sizeX, sizeY)
    return mod1(i, sizeX) + sizeX * (mod1(j, sizeY) - 1)
end

function to_grid(linear, sizeX, sizeY)
    return (mod1(linear, sizeX), div(linear - 1, sizeX) + 1)
end

function kitaevX(geometry::PeriodicHoneycombGeometry)
    @assert geometry.sizeX % 2 == 0 "The sizeX must be even"
    @assert geometry.sizeY % 2 == 0 "The sizeY must be even"
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

function kitaevY(geometry::PeriodicHoneycombGeometry)
    @assert geometry.sizeX % 2 == 0 "The sizeX must be even"
    @assert geometry.sizeY % 2 == 0 "The sizeY must be even"
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

function kitaevZ(geometry::PeriodicHoneycombGeometry)
    @assert geometry.sizeX % 2 == 0 "The sizeX must be even"
    @assert geometry.sizeY % 2 == 0 "The sizeY must be even"
    bonds = Tuple{Int64,Int64}[]
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    # for i in 1:sizeX*sizeY
    #     if iseven(i)
    #         push!(bonds, (mod1(i + sizeX * sizeY - 1, sizeX * sizeY), mod1(i - sizeX * sizeY + 1, sizeX * sizeY)))
    #     end
    # end
    for j in 1:sizeY
        for i in 2:2:sizeX
            push!(bonds, (to_linear(i, j, sizeX, sizeY), to_linear(i - 1, j + 1, sizeX, sizeY)))
        end
    end
    return bonds
end

function isKitaevX(geometry::PeriodicHoneycombGeometry, bond::Tuple{Int64,Int64})
    @assert geometry.sizeX % 2 == 0 "The sizeX must be even"
    @assert geometry.sizeY % 2 == 0 "The sizeY must be even"
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    i_x, i_y = to_grid(bond[1], sizeX, sizeY)
    j_x, j_y = to_grid(bond[2], sizeX, sizeY)

    # if i_y == j_y
    #     if ((i_x % 2 == 1 && j_x == mod1(i_x + 1, sizeX))
    #         ||
    #         (j_x % 2 == 1 && i_x == mod1(j_x + 1, sizeX)))
    #         return true
    #     end
    # end
    # return false
    xxs = kitaevX(geometry)
    if bond in xxs || (bond[2], bond[1]) in xxs
        return true
    end
    return false
end

function isKitaevY(geometry::PeriodicHoneycombGeometry, bond::Tuple{Int64,Int64})
    @assert geometry.sizeX % 2 == 0 "The sizeX must be even"
    @assert geometry.sizeY % 2 == 0 "The sizeY must be even"
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    i_x, i_y = to_grid(bond[1], sizeX, sizeY)
    j_x, j_y = to_grid(bond[2], sizeX, sizeY)

    # if i_y == j_y
    #     if ((i_x % 2 == 0 && j_x == mod1(i_x + 1, sizeX))
    #         ||
    #         (j_x % 2 == 0 && i_x == mod1(j_x + 1, sizeX)))
    #         return true
    #     end
    # end
    # return false
    yys = kitaevY(geometry)
    if bond in yys || (bond[2], bond[1]) in yys
        return true
    end
    return false
end

function isKitaevZ(geometry::PeriodicHoneycombGeometry, bond::Tuple{Int64,Int64})
    @assert geometry.sizeX % 2 == 0 "The sizeX must be even"
    @assert geometry.sizeY % 2 == 0 "The sizeY must be even"
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    i_x, i_y = to_grid(bond[1], sizeX, sizeY)
    j_x, j_y = to_grid(bond[2], sizeX, sizeY)

    # if i_x == j_x
    #     if (((j_y == mod1(i_y + 1, sizeY)) || (i_y == mod1(j_y + 1, sizeY)))) && ((iseven(i_y) && iseven(i_x) && isodd(j_x) && isodd(j_y)) || (iseven(j_y) && iseven(j_x) && isodd(i_x) && isodd(i_y)))
    #         return true
    #     end
    # end

    zzs = kitaevZ(geometry)
    if bond in zzs || (bond[2], bond[1]) in zzs
        return true
    end
    return false
end

function kitaevType(geometry::PeriodicHoneycombGeometry, bond::Tuple{Int64,Int64})
    @assert geometry.sizeX % 2 == 0 "The sizeX must be even"
    @assert geometry.sizeY % 2 == 0 "The sizeY must be even"
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

function isKitaev_(type::Symbol, geometry::PeriodicHoneycombGeometry, bond::Tuple{Int64,Int64})
    @assert geometry.sizeX % 2 == 0 "The sizeX must be even"
    @assert geometry.sizeY % 2 == 0 "The sizeY must be even"
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

function kitaevX_neighbor(geometry::PeriodicHoneycombGeometry, site::Integer)
    @assert geometry.sizeX % 2 == 0 "The sizeX must be even"
    @assert geometry.sizeY % 2 == 0 "The sizeY must be even"
    for n in Graphs.neighbors(geometry.graph, site)
        if isKitaevX(geometry, (site, n))
            return n
        end
    end
end

function kitaevY_neighbor(geometry::PeriodicHoneycombGeometry, site::Integer)
    @assert geometry.sizeX % 2 == 0 "The sizeX must be even"
    @assert geometry.sizeY % 2 == 0 "The sizeY must be even"
    for n in Graphs.neighbors(geometry.graph, site)
        if isKitaevY(geometry, (site, n))
            return n
        end
    end
end

function kitaevZ_neighbor(geometry::PeriodicHoneycombGeometry, site::Integer)
    @assert geometry.sizeX % 2 == 0 "The sizeX must be even"
    @assert geometry.sizeY % 2 == 0 "The sizeY must be even"
    for n in Graphs.neighbors(geometry.graph, site)
        if isKitaevZ(geometry, (site, n))
            return n
        end
    end
end

function plaquettes(geometry::PeriodicHoneycombGeometry)
    @assert geometry.sizeX % 2 == 0 "The sizeX must be even"
    @assert geometry.sizeY % 2 == 0 "The sizeY must be even"
    # mysimplecycles_limited_length(geometry.graph, 6)
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
function long_cycles(geometry::PeriodicHoneycombGeometry)
    @assert geometry.sizeX % 2 == 0 "The sizeX must be even"
    @assert geometry.sizeY % 2 == 0 "The sizeY must be even"
    loop1 = Int64[1]
    loop2 = Int64[1]
    # loop3 = Int64[1]
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

    # n = 1
    # for i in 1:2sizeX-1
    #     if isodd(i)
    #         n = kitaevZ_neighbor(geometry, n)
    #         push!(loop3, n)
    #     elseif isodd(2i)
    #         n = kitaevY_neighbor(geometry, n)
    #         push!(loop3, n)
    #     else
    #         n = kitaevX_neighbor(geometry, n)
    #         push!(loop3, n)
    #     end
    # end

    return [loop1, loop2]
end

function random_qubit(geometry::PeriodicHoneycombGeometry)
    return rand(1:nv(geometry.graph))
end




using CairoMakie
function plotLattice(geometry::PeriodicHoneycombGeometry)
    fig = Figure()
    ax = Axis(fig[1, 1])

    scatter!(ax, geometry.gridPositions)
    grid = geometry.gridPositions
    xPoints = []
    for x in kitaevX(geometry)
        push!(xPoints, Point2f(grid[x[1]]))
        push!(xPoints, Point2f(grid[x[2]]))
    end
    yPoints = []
    for x in kitaevY(geometry)
        push!(yPoints, Point2f(grid[x[1]]))
        push!(yPoints, Point2f(grid[x[2]]))
    end
    zPoints = []
    for x in kitaevZ(geometry)
        push!(zPoints, Point2f(grid[x[1]]))
        push!(zPoints, Point2f(grid[x[2]]))
    end
    linesegments!(ax, xPoints, color=:red)
    # linesegments!(ax, yPoints, color=:green)
    linesegments!(ax, zPoints, color=:blue)
    save("test.png", fig)
    display(fig)
end

function plotLattice2(geometry::PeriodicHoneycombGeometry)
    fig = Figure()
    ax = Axis(fig[1, 1])

    scatter!(ax, geometry.gridPositions)
    grid = geometry.gridPositions
    plaq = plaquettes(geometry)

    for p in plaq[1:1]
        points = []
        for x in p
            push!(points, Point2f(grid[x]))
            # push!(xPoints, Point2f(grid[x[2]]))
        end
        push!(points, Point2f(grid[p[1]]))
        lines!(ax, points)
    end

    save("test.png", fig)
    display(fig)
end

function plotLattice3(geometry::PeriodicHoneycombGeometry)
    fig = Figure()
    ax = Axis(fig[1, 1])

    scatter!(ax, geometry.gridPositions)
    grid = geometry.gridPositions
    loops = long_cycles(geometry)

    points = []
    for x in loops[2]
        push!(points, Point2f(grid[x]))
        # push!(xPoints, Point2f(grid[x[2]]))
    end
    lines!(ax, points)


    save("test.png", fig)
    display(fig)
end


# function kitaevBonds(lattice::PeriodicHoneycombGeometry)
#     @assert lattice.sizeX % 2 == 0 "The sizeX must be even"
#     @assert lattice.sizeY % 2 == 0 "The sizeY must be even"
#     positions = [(neighbors(lattice.graph, i)[1], i, neighbors(lattice.graph, i)[2]) for i in nQubits(lattice)+1:nv(lattice.graph)]
#     pointers = vcat([1, 2, 3], repeat([2, 3, 1, 3], div(lattice.sizeX - 2, 2)), [3],
#         repeat(vcat([2, 1], repeat([1, 3, 2], div(lattice.sizeX - 2, 2)), [3],
#                 [1, 2, 3], repeat([2, 1, 3], div(lattice.sizeX - 2, 2))), div(lattice.sizeY - 2, 2)),
#         [2, 1], repeat([1, 2], div(lattice.sizeX - 2, 2)))


#     possibleXX = [p for (i, p) in enumerate(positions) if pointers[i] == 2]
#     possibleYY = [p for (i, p) in enumerate(positions) if pointers[i] == 3]
#     possibleZZ = [p for (i, p) in enumerate(positions) if pointers[i] == 1]
#     return possibleZZ, possibleXX, possibleYY
# end



# function kekuleBonds(lattice::PeriodicHoneycombGeometry)
#     @assert lattice.sizeX % 6 == 0 "The sizeX must be a multiple of 6"
#     @assert lattice.sizeY % 2 == 0 "The sizeY must be even"
#     positions = [(neighbors(lattice.graph, i)[1], i, neighbors(lattice.graph, i)[2]) for i in nQubits(lattice)+1:nv(lattice.graph)]
#     pointers = vcat(
#         [1, 3, 2, 2, 3, 3, 1, 1, 2, 2, 3, 3, 1], repeat([1, 2, 2, 3, 3, 1, 1, 2, 2, 3, 3, 1], div(lattice.sizeX, 6) - 2), [3, 2, 2, 3, 3, 1, 1, 2, 2, 3, 1],
#         repeat(vcat(
#                 [1, 3, 2, 3, 3, 1, 2, 2, 3, 1], # 4
#                 repeat([1, 2, 3, 3, 1, 2, 2, 3, 1], div(lattice.sizeX, 6) - 2),
#                 [1, 2, 3, 3, 1, 2, 2, 1],
#                 [1, 3, 2, 2, 3, 1, 1, 2, 3, 3], # 3
#                 repeat([1, 2, 2, 3, 1, 1, 2, 3, 3], div(lattice.sizeX, 6) - 2), [1, 2, 2, 3, 1, 1, 2, 3],
#             ), div(lattice.sizeY, 2) - 1),
#         [1, 3, 2, 3, 1, 2, 3], repeat([1, 2, 3, 1, 2, 3], div(lattice.sizeX, 6) - 2), [1, 2, 3, 1, 2])


#     possibleXX = [p for (i, p) in enumerate(positions) if pointers[i] == 2]
#     possibleYY = [p for (i, p) in enumerate(positions) if pointers[i] == 3]
#     possibleZZ = [p for (i, p) in enumerate(positions) if pointers[i] == 1]
#     return possibleZZ, possibleXX, possibleYY
# end
