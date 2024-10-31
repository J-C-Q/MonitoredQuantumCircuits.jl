using CairoMakie
using CairoMakie.GeometryBasics
using JLD2
using LinearAlgebra

function projection(point; origin=[1 / 3, 1 / 3, 1 / 3], e1=normalize(cross(normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]), normalize([1 / 3, 1 / 3, 1 / 3]))), e2=normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]))

    return sum(e1 .* (point .- origin)), sum(e2 .* (point .- origin))
end
function generateProbs(; N=15)
    points = NTuple{3,Float64}[]
    n = Int(-1 / 2 + sqrt(1 / 4 + 2N))
    for (k, i) in enumerate(range(0, 1, n))
        for j in range(i, 1, n - k + 1)
            px = i
            py = j - i
            pz = 1 - j
            push!(points, (px, py, pz))
        end
    end

    return [p .- 0.5 .* (p .- (1 / 3, 1 / 3, 1 / 3)) for p in points]
end
function PlotThis()
    tmis = JLD2.load("tmis_24x24_1500.jld2")["results"]
    tmis = []
    points = []
    for file in readdir("data/data")
        if !occursin("raw", file)
            push!(tmis, JLD2.load("data/data/$(file)")["result"])
            push!(points, JLD2.load("data/data/$(file)")["parameter"])
        end
    end
    # tmis .-= 1
    # println(tmis)
    # points = JLD2.load("tmis_24x24_1500.jld2")["data"]
    # points = generateProbs()
    # tmis = (1:length(points)) ./ length(points)
    points2d = [projection(p) for p in unique(points)]

    averagedTmis = Vector{Float64}(undef, length(unique(points)))
    for (i, p) in enumerate(unique(points))
        averagedTmis[i] = 0.0
        indeces = findall(x -> x == p, points)
        for j in indeces
            averagedTmis[i] += tmis[j]
        end
        averagedTmis[i] /= length(indeces)
    end

    fig = Figure()
    ax = Axis(fig[1, 1], aspect=DataAspect())
    hidedecorations!(ax)
    voronoiplot!(ax, [p[1] for p in points2d], [p[2] for p in points2d], averagedTmis, colormap=:viridis, markersize=5, strokewidth=0.5, colorrange=(-1, 1), unbounded_edge_extension_factor=1.0)
    p = Polygon(
        Point2f[(-0.8, -0.5), (0.8, -0.5), (0.8, 0.9), (-0.8, 0.9)],
        [Point2f[
            projection([1, 0, 0]),
            projection([0, 1, 0]),
            projection([0, 0, 1])
        ]]
    )
    poly!(p, color=:white)
    lines!(ax, [
            projection([1, 0, 0]),
            projection([0, 1, 0]),
            projection([0, 0, 1]),
            projection([1, 0, 0])], color=:black)
    limits!(ax, (-0.8, 0.8), (-0.5, 0.9))
    Colorbar(fig[1, 2], limits=(-1, 1), colormap=:viridis,
        flipaxis=true, label="Tripartite Information")
    fig
end
PlotThis()
