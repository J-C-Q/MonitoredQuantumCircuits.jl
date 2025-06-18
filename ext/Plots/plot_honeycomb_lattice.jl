function MonitoredQuantumCircuits.drawGeometry(geometry::HoneycombGeometry; brickwork::Bool=false)
    graph = geometry.graph
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    offset = 0.28867513459481287
    if brickwork
        xmin, xmax, ymin, ymax = 0.5, sizeX + 0.5, 0.5, sizeY + 0.5
    else
        xmin, xmax, ymin, ymax = 0.5, sizeX + 0.5, 2-4offset,  sizeY*(4offset
        +2offset) +3offset
    end
    Lx = xmax - xmin
    Ly = ymax - ymin


    fig = Figure()
    ax = Axis(fig[1, 1], aspect=DataAspect(), xgridvisible=false, ygridvisible=false)
    hidedecorations!(ax)
    points = Point2f[]


    for j in 1:sizeY
        for i in 1:sizeX

            if brickwork
                push!(points, Point2f(mod1(i ,sizeX), j))
            else
                push!(points, Point2f(mod1(i,sizeX), j*(4offset
            +2offset) + offset * iseven(i) - offset * isodd(i)))
            end
        end
    end
    connections = Point2f[]
    periodic = Point2f[]
    for i in 1:Graphs.nv(graph)
        neighbors = Graphs.neighbors(graph, i)
        for neighbor in neighbors
            if Makie.norm(points[i] - points[neighbor]) > 2
                push!(periodic, points[i])

                images_i = [
                    points[i] + Point2f(Lx, 0),
                    points[i] - Point2f(Lx, 0),
                    points[i] + Point2f(0, Ly),
                    points[i] - Point2f(0, Ly),
                    points[i] + Point2f(Lx, Ly),
                    points[i] - Point2f(Lx, Ly),
                    points[i] + Point2f(-Lx, Ly),
                    points[i] + Point2f(Lx, -Ly)]
                images_neighbor = [
                    points[neighbor] + Point2f(Lx, 0),
                    points[neighbor] - Point2f(Lx, 0),
                    points[neighbor] + Point2f(0, Ly),
                    points[neighbor] - Point2f(0, Ly),
                    points[neighbor] + Point2f(Lx, Ly),
                    points[neighbor] - Point2f(Lx, Ly),
                    points[neighbor] + Point2f(-Lx, Ly),
                    points[neighbor] + Point2f(Lx, -Ly)]

                diffs1 = [Makie.norm(points[i] - img) for img in images_neighbor]
                min_diff = argmin(diffs1)
                push!(periodic, images_neighbor[min_diff])
                push!(periodic, Point2f(NaN, NaN))
                diffs2 = [Makie.norm(points[neighbor] - img) for img in images_i]
                min_diff = argmin(diffs2)
                push!(periodic, images_i[min_diff])

                push!(periodic, points[neighbor])
                push!(periodic, Point2f(NaN, NaN))  # Add a NaN point to break the line
            else

                push!(connections, points[i])
                push!(connections, points[neighbor])
                push!(connections, Point2f(NaN, NaN))
            end
        end
    end

    lines!(ax, connections, color=:black,  linewidth=1)
    lines!(ax, periodic, color=:black, linewidth=1)
    scatter!(ax, points, markersize=0.5, color=:white, strokecolor=:black, strokewidth=1.0, markerspace=:data)
    text!(ax, points, text=string.(1:length(points)), color=:black, align=(:center, :center), fontsize=0.16, markerspace=:data)
    limits!(ax, xmin, xmax, ymin, ymax)
    display(fig)
end
