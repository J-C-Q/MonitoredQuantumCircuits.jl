using CairoMakie
using CairoMakie.GeometryBasics
using JLD2
using LinearAlgebra

function projection(point; origin=[1 / 3, 1 / 3, 1 / 3], e1=normalize(cross(normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]), normalize([1 / 3, 1 / 3, 1 / 3]))), e2=normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]))

    return sum(e1 .* (point .- origin)), sum(e2 .* (point .- origin))
end

function PlotThis()
    entanglements = JLD2.load("simulation_24x24_entanglement.jld2")["results"]
    points = JLD2.load("simulation_24x24_entanglement.jld2")["data"]
    points2d = [projection(p[1]) for p in points]

    fig = Figure()
    ax = Axis(fig[1, 1], xlabel="subsystem size", ylabel="entanglement", title="Hexagon Kitaev with pbc")
    ax2 = Axis(fig[1, 2], aspect=DataAspect())
    hidedecorations!(ax2)
    # hlines!(ax, [0.5], color=:red)
    # text!(ax, [(0.01, 0.5)], text="1/2", color=:red)
    for i in length(points)-6:length(points)

        scatter!(ax, collect(1:24*24) ./ (24 * 24), [e for e in entanglements[i]][1:24*24], color=i / length(points), colorrange=(0.0, 1.0))
    end

    # limits!(ax, (10^-2, 1000), (0, 1))
    # fig

    # voronoiplot!(ax, [p[1] for p in points2d], [p[2] for p in points2d], tmis, colormap=:viridis, markersize=1, strokewidth=0.5, colorrange=(-1, 1))
    p = Polygon(
        Point2f[(-0.8, -0.5), (0.8, -0.5), (0.8, 0.9), (-0.8, 0.9)],
        [Point2f[
            projection([1, 0, 0]),
            projection([0, 1, 0]),
            projection([0, 0, 1])
        ]]
    )
    poly!(ax2, p, color=:white)
    lines!(ax2, [
            projection([1, 0, 0]),
            projection([0, 1, 0]),
            projection([0, 0, 1]),
            projection([1, 0, 0])], color=:black)
    scatter!(ax2, points2d, color=[i / length(points) for i in 1:length(points)], colorrange=(0.0, 1.0))
    text!(ax2, [projection((1.1, 0.0, 0.0)), projection((0.0, 1.1, 0.0)), projection((0.0, 0.0, 1.1))], text=["X", "Y", "Z"], align=(:center, :center))
    limits!(ax2, (-0.9, 0.9), (-0.6, 1.0))
    # Colorbar(fig[1, 2], limits=(-1, 1), colormap=:viridis,
    #     flipaxis=true, label="Tripartite Information")
    fig
end
PlotThis()
