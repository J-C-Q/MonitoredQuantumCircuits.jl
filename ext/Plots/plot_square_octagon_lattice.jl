function MonitoredQuantumCircuits.drawGeometry(geometry::SquareOctagonGeometry)
    graph = geometry.graph
    sizeX = geometry.sizeX
    sizeY = geometry.sizeY
    xmin, xmax, ymin, ymax = 0.5, sizeX + 0.5, 0.5, sizeY + 0.5
    Lx = xmax - xmin
    Ly = ymax - ymin

    fig = Figure()
    ax = Axis(fig[1, 1], aspect=DataAspect(), xgridvisible=false, ygridvisible=false)
    hidedecorations!(ax)
    points = Point2f[]
    for j in 1:sizeY
        for i in 1:sizeX

            push!(points, Point2f(i - 0.3, j))
            push!(points, Point2f(i, j - 0.3))
            push!(points, Point2f(i + 0.3, j))
            push!(points, Point2f(i, j + 0.3))
        end
    end
    connections = Point2f[]
    for i in 1:Graphs.nv(graph)
        neighbors = Graphs.neighbors(graph, i)
        for neighbor in neighbors
            if Makie.norm(points[i] - points[neighbor]) > 1
                push!(connections, points[i])

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
                push!(connections, images_neighbor[min_diff])
                push!(connections, Point2f(NaN, NaN))
                diffs2 = [Makie.norm(points[neighbor] - img) for img in images_i]
                min_diff = argmin(diffs2)
                push!(connections, images_i[min_diff])

                push!(connections, points[neighbor])
                push!(connections, Point2f(NaN, NaN))  # Add a NaN point to break the line
            else

                push!(connections, points[i])
                push!(connections, points[neighbor])
                push!(connections, Point2f(NaN, NaN))
            end
        end
    end
    # lines!(ax, connections, color=:black, linewidth=1)



    # z connections

    zconnections = Point2f[]
    for i in 1:Graphs.nv(graph)
        neighbor = MonitoredQuantumCircuits.Z_neighbor(geometry, i)

        if Makie.norm(points[i] - points[neighbor]) > 1
            push!(zconnections, points[i])

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
            push!(zconnections, images_neighbor[min_diff])
            push!(zconnections, Point2f(NaN, NaN))
            diffs2 = [Makie.norm(points[neighbor] - img) for img in images_i]
            min_diff = argmin(diffs2)
            push!(zconnections, images_i[min_diff])

            push!(zconnections, points[neighbor])
            push!(zconnections, Point2f(NaN, NaN))  # Add a NaN point to break the line
        else

            push!(zconnections, points[i])
            push!(zconnections, points[neighbor])
            push!(zconnections, Point2f(NaN, NaN))
        end

    end
    # lines!(ax, zconnections, color=:black, linewidth=1)
    lines!(ax, zconnections, color=:blue, linewidth=1)

    # x connections
    xconnections = Point2f[]
    for i in 1:Graphs.nv(graph)
        neighbor = MonitoredQuantumCircuits.X_neighbor(geometry, i)

        if Makie.norm(points[i] - points[neighbor]) > 1
            push!(xconnections, points[i])

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
            push!(xconnections, images_neighbor[min_diff])
            push!(xconnections, Point2f(NaN, NaN))
            diffs2 = [Makie.norm(points[neighbor] - img) for img in images_i]
            min_diff = argmin(diffs2)
            push!(xconnections, images_i[min_diff])

            push!(xconnections, points[neighbor])
            push!(xconnections, Point2f(NaN, NaN))  # Add a NaN point to break the line
        else

            push!(xconnections, points[i])
            push!(xconnections, points[neighbor])
            push!(xconnections, Point2f(NaN, NaN))
        end

    end
    # lines!(ax, xconnections, color=:black, linewidth=1)
    lines!(ax, xconnections, color=:red, linewidth=1)


    # y connections
    yconnections = Point2f[]
    for i in 1:Graphs.nv(graph)
        neighbor = MonitoredQuantumCircuits.Y_neighbor(geometry, i)

        if Makie.norm(points[i] - points[neighbor]) > 1
            push!(yconnections, points[i])

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
            push!(yconnections, images_neighbor[min_diff])
            push!(yconnections, Point2f(NaN, NaN))
            diffs2 = [Makie.norm(points[neighbor] - img) for img in images_i]
            min_diff = argmin(diffs2)
            push!(yconnections, images_i[min_diff])

            push!(yconnections, points[neighbor])
            push!(yconnections, Point2f(NaN, NaN))  # Add a NaN point to break the line
        else

            push!(yconnections, points[i])
            push!(yconnections, points[neighbor])
            push!(yconnections, Point2f(NaN, NaN))
        end

    end
    # lines!(ax, yconnections, color=:black, linewidth=1)
    lines!(ax, yconnections, color=:green, linewidth=1)












    scatter!(ax, points, markersize=0.2, color=:white, strokecolor=:black, strokewidth=1.0, markerspace=:data)
    text!(ax, points, text=string.(1:length(points)), color=:black, align=(:center, :center), fontsize=0.05, markerspace=:data)
    limits!(ax, xmin, xmax, ymin, ymax)
    display(fig)
end
