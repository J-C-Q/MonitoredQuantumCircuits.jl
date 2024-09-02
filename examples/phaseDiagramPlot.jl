using CairoMakie
using CairoMakie.GeometryBasics
using JLD2
using LinearAlgebra

function projection(point; origin=[1 / 3, 1 / 3, 1 / 3], e1=normalize(cross(normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]), normalize([1 / 3, 1 / 3, 1 / 3]))), e2=normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]))

    return sum(e1 .* (point .- origin)), sum(e2 .* (point .- origin))
end

function PlotThis()
    tmis = JLD2.load("tmis.jld2")["results"]
    println(tmis)
    points = JLD2.load("tmis.jld2")["data"]
    points2d = [projection(p) for p in points]

    fig = Figure()
    ax = Axis(fig[1, 1], aspect=DataAspect())
    hidedecorations!(ax)
    voronoiplot!(ax, [p[1] for p in points2d], [p[2] for p in points2d], tmis, colormap=:viridis, markersize=1, strokewidth=0.5)
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
    Colorbar(fig[1, 2], limits=(minimum(tmis), maximum(tmis)), colormap=:viridis,
        flipaxis=true, label="Tripartite Information")
    fig
end
PlotThis()
