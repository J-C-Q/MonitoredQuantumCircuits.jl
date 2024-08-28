using CairoMakie
using CairoMakie.GeometryBasics
using JLD2
using LinearAlgebra

function projection(point, origin, e1, e2)

    return sum(e1 .* (point .- origin)), sum(e2 .* (point .- origin))
end

function PlotThis()
    tmis = JLD2.load("tmis.jld2")["tmis"]
    points = JLD2.load("tmis.jld2")["points"]
    points2d = [projection(p, [1 / 3, 1 / 3, 1 / 3], normalize(cross(normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]), normalize([1 / 3, 1 / 3, 1 / 3]))), normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3])) for p in points]

    fig = Figure()
    ax = Axis(fig[1, 1], aspect=DataAspect())
    hidedecorations!(ax)
    voronoiplot!(ax, [p[1] for p in points2d], [p[2] for p in points2d], tmis, colormap=:viridis)
    p = Polygon(
        Point2f[(-0.8, -0.5), (0.8, -0.5), (0.8, 0.9), (-0.8, 0.9)],
        [Point2f[
            projection([1, 0, 0], [1 / 3, 1 / 3, 1 / 3], normalize(cross(normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]), normalize([1 / 3, 1 / 3, 1 / 3]))), normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3])),
            projection([0, 1, 0], [1 / 3, 1 / 3, 1 / 3], normalize(cross(normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]), normalize([1 / 3, 1 / 3, 1 / 3]))), normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3])),
            projection([0, 0, 1], [1 / 3, 1 / 3, 1 / 3], normalize(cross(normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]), normalize([1 / 3, 1 / 3, 1 / 3]))), normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]))
        ]]
    )
    poly!(p, color=:white)
    lines!(ax, [
            projection([1, 0, 0], [1 / 3, 1 / 3, 1 / 3], normalize(cross(normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]), normalize([1 / 3, 1 / 3, 1 / 3]))), normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3])),
            projection([0, 1, 0], [1 / 3, 1 / 3, 1 / 3], normalize(cross(normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]), normalize([1 / 3, 1 / 3, 1 / 3]))), normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3])),
            projection([0, 0, 1], [1 / 3, 1 / 3, 1 / 3], normalize(cross(normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]), normalize([1 / 3, 1 / 3, 1 / 3]))), normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3])),
            projection([1, 0, 0], [1 / 3, 1 / 3, 1 / 3], normalize(cross(normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]), normalize([1 / 3, 1 / 3, 1 / 3]))), normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]))], color=:black)
    limits!(ax, (-0.8, 0.8), (-0.5, 0.9))
    Colorbar(fig[1, 2], limits=(minimum(tmis), maximum(tmis)), colormap=:viridis,
        flipaxis=true, label="Tripartite Information")
    fig
end
PlotThis()
