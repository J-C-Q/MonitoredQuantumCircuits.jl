struct SquareOctagonGeometry{T<:BoundaryCondition} <: Geometry
    graph::Graph
    sizeX::Int64
    sizeY::Int64

    function SquareOctagonGeometry(type::Type{Open}, sizeX::Integer, sizeY::Integer)
        graph = Graphs.SimpleGraph(4 * sizeX * sizeY)

        for i in 1:sizeX
            for j in 1:sizeY
                site = 4 * ((j - 1) * sizeX + i - 1) + 1

                Graphs.add_edge!(graph, site, site + 1)
                Graphs.add_edge!(graph, site + 1, site + 2)
                Graphs.add_edge!(graph, site + 2, site + 3)
                Graphs.add_edge!(graph, site, site + 3)


                if i < sizeX
                    Graphs.add_edge!(graph, site + 2, site + 4)
                end
                if j < sizeY
                    Graphs.add_edge!(graph, site + 1, site + 4 * sizeX + 3)
                end
            end
        end

        return new{type}(graph, sizeX, sizeY)
    end
    function SquareOctagonGeometry(type::Type{Periodic}, sizeX::Integer, sizeY::Integer)
        graph = Graphs.SimpleGraph(4 * sizeX * sizeY)

        for i in 1:sizeX
            for j in 1:sizeY
                site = 4 * ((j - 1) * sizeX + i - 1) + 1

                Graphs.add_edge!(graph, site, site + 1)
                Graphs.add_edge!(graph, site + 1, site + 2)
                Graphs.add_edge!(graph, site + 2, site + 3)
                Graphs.add_edge!(graph, site, site + 3)


                if i < sizeX
                    Graphs.add_edge!(graph, site + 2, site + 4)
                else
                    Graphs.add_edge!(graph, site + 2, 4 * ((j - 1) * sizeX) + 1)
                end
                if j < sizeY
                    Graphs.add_edge!(graph, site + 3, site + 4 * sizeX + 1)
                else
                    Graphs.add_edge!(graph, site + 3, 4 * (i - 1) + 2)
                end
            end
        end

        return new{type}(graph, sizeX, sizeY)
    end
end

function visualize(io::IO, geometry::SquareOctagonGeometry)
end

function bondsX(geometry::SquareOctagonGeometry)
    bonds = Int64[]
    for i in 1:geometry.sizeX
        for j in 1:geometry.sizeY
            site = 4 * ((j - 1) * geometry.sizeX + i - 1) + 1
            push!(bonds, site)
            push!(bonds, site + 1)
            push!(bonds, site + 2)
            push!(bonds, site + 3)
        end
    end
    return reshape(bonds, 2, length(bonds) ÷ 2)
end

function bondsY(geometry::SquareOctagonGeometry)
    bonds = Int64[]
    for i in 1:geometry.sizeX
        for j in 1:geometry.sizeY
            site = 4 * ((j - 1) * geometry.sizeX + i - 1) + 1
            push!(bonds, site + 1)
            push!(bonds, site + 2)
            push!(bonds, site)
            push!(bonds, site + 3)
        end
    end
    return reshape(bonds, 2, length(bonds) ÷ 2)
end

function bondsZ(geometry::SquareOctagonGeometry{Open})
    bonds = Int64[]
    for i in 1:geometry.sizeX
        for j in 1:geometry.sizeY
            site = 4 * ((j - 1) * geometry.sizeX + i - 1) + 1
            if i < geometry.sizeX
                push!(bonds, site + 2)
                push!(bonds, site + 4)
            end
            if j < geometry.sizeY
                push!(bonds, site + 1)
                push!(bonds, site + 4 * geometry.sizeX + 3)
            end
        end
    end
    return reshape(bonds, 2, length(bonds) ÷ 2)
end

function bondsZ(geometry::SquareOctagonGeometry{Periodic})
    bonds = Int64[]
    for i in 1:geometry.sizeX
        for j in 1:geometry.sizeY
            site = 4 * ((j - 1) * geometry.sizeX + i - 1) + 1
            if i < geometry.sizeX
                push!(bonds, site + 2)
                push!(bonds, site + 4)

            else
                push!(bonds, site + 2)
                push!(bonds, 4 * ((j - 1) * geometry.sizeX) + 1)
            end
            if j < geometry.sizeY
                push!(bonds, site + 1)
                push!(bonds, site + 4 * geometry.sizeX + 3)
            else
                push!(bonds, site + 1)
                push!(bonds, 4 * (i - 1) + 4)
            end
        end
    end
    return reshape(bonds, 2, length(bonds) ÷ 2)
end



function subsystems(geometry::SquareOctagonGeometry{Periodic}, n::Integer=2; cutType=:Z)
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    if cutType == :Z_VERTICAL
        sizeY % n == 0 || throw(ArgumentError("sizeY must be divisible by n. n=$n sub systems not possible."))
        N = sizeY ÷ n * sizeX * 4

        return hcat([collect((i-1)*N+1:i*N) for i in 1:n]...)
    elseif cutType == :XY_VERTICAL
        sizeY % n == 0 || throw(ArgumentError("sizeY must be divisible by n. n=$n sub systems not possible."))
        N = ((sizeY ÷ n) - 1) * sizeX * 4

        return hcat([vcat(collect((i-1)*N+1:i*N)) for i in 1:n]...)
    end

end


function Z_neighbor(geometry::SquareOctagonGeometry{Periodic}, site::Integer)
    n = div(site - 1, 4) + 1
    y = div(n - 1, geometry.sizeX) + 1
    x = n - (y - 1) * geometry.sizeX

    if site % 4 == 1
        if x == 1
            return site + 4 * (geometry.sizeX - 1) + 2
        else
            return site - 2
        end
    elseif site % 4 == 2
        if y == 1
            return site + 4 * ((geometry.sizeY - 1) * geometry.sizeX) + 2
        else
            return site - 4 * (geometry.sizeX) + 2
        end
    elseif site % 4 == 3
        if x == geometry.sizeX
            return site - 4 * (geometry.sizeX - 1) -2
        else
            return site + 2
        end
    elseif site % 4 == 0
        if y == geometry.sizeY
            return site - 4 * ((geometry.sizeY - 1) * geometry.sizeX) -2
        else
            return site + 4 * (geometry.sizeX) - 2
        end
    end
end

function X_neighbor(geometry::SquareOctagonGeometry{Periodic}, site::Integer)
    n = div(site - 1, 4) + 1
    y = div(n - 1, geometry.sizeX) + 1
    x = n - (y - 1) * geometry.sizeX

    if site % 4 == 1
        return site + 3
    elseif site % 4 == 2
        return site + 1
    elseif site % 4 == 3
        return site - 1
    elseif site % 4 == 0
        return site - 3
    end
end

function Y_neighbor(geometry::SquareOctagonGeometry{Periodic}, site::Integer)
    n = div(site - 1, 4) + 1
    y = div(n - 1, geometry.sizeX) + 1
    x = n - (y - 1) * geometry.sizeX

    if site % 4 == 1
        return site + 1
    elseif site % 4 == 2
        return site -1
    elseif site % 4 == 3
        return site +1
    elseif site % 4 == 0
        return site - 1
    end
end

function loops(geometry::SquareGeometry{Periodic}; types=(:X, :Z))
    types[1] != types[2] || throw(ArgumentError("The types can not be the same"))
    loops = Int64[]
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    if types == (:X, :Z)
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
