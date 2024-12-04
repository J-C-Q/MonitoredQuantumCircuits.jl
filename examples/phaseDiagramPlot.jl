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
    # tmis = JLD2.load("tmis_24x24_1500.jld2")["results"]
    folders = ["data3/data"]
    tmis = []
    points = []
    for folder in folders
        for file in readdir(folder)
            if !occursin("raw", file)
                push!(tmis, JLD2.load("$(folder)/$(file)")["result"])
                push!(points, JLD2.load("$(folder)/$(file)")["parameter"])
            end
        end
    end
    # for file in readdir("data2")
    #     if !occursin("raw", file)
    #         push!(tmis, JLD2.load("data2/$(file)")["result"])
    #         push!(points, JLD2.load("data2/$(file)")["parameter"])
    #     end
    # end
    points2d = [projection(p) for p in unique(points)]
    # points2dFlipx = [Point2f(-1 * p[1], p[2]) for p in points2d]
    # println(points2d)
    averagedTmis = Vector{Float64}(undef, length(unique(points)))

    stupid = length(range(1, 24 * 24 - 1, 50))


    for (i, p) in enumerate(unique(points))
        averagedTmis[i] = 0.0
        indeces = findall(x -> all(x .≈ p), points)
        for j in indeces
            averagedTmis[i] += tmis[j]
        end
        averagedTmis[i] /= length(indeces) * stupid
    end
    print(vcat(averagedTmis, averagedTmis))
    fig = Figure()
    ax = Axis(fig[1, 1], aspect=DataAspect())
    hidedecorations!(ax)
    voronoiplot!(ax, [p[1] for p in points2d], [p[2] for p in points2d], averagedTmis, colormap=:vik10, markersize=5, strokewidth=0.5, unbounded_edge_extension_factor=1.0, colorrange=(-1, 1), highclip=:white, lowclip=:white, nan_color=:black)
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
    lines!(ax, [norm(projection([0.5, 0.5, 0])) * cos(t) for t in range(0, 2π, length=100)], [norm(projection([0.5, 0.5, 0])) * sin(t) for t in range(0, 2π, length=100)], color=:red, linewidth=2)
    text!(ax, Point2f[projection([1.05, 0, 0]), projection([0, 1.05, 0]), projection([0, 0, 1.05])], text=["X", "Y", "Z"], color=:black, align=(:center, :center))
    limits!(ax, (-0.8, 0.8), (-0.5, 0.9))
    Colorbar(fig[1, 2], limits=(-1, 1), colormap=:vik10,
        flipaxis=true, label="Tripartite Information")
    fig
end
PlotThis()
