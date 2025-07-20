using CairoMakie
using JLD2
using LinearAlgebra

function projection(point; origin=[1 / 3, 1 / 3, 1 / 3], e1=normalize(cross(normalize([0.0, 0.0, 1.0] .- origin), normalize(origin))), e2=normalize([0.0, 0.0, 1.0] .- origin))

    return sum(e1 .* (point .- origin)), sum(e2 .* (point .- origin))
end

function purificationPlot(file::String, data_path::String; L=12, averaging=10)
    points = [
        (1 / 3, 1 / 3, 1 / 3),
        (0.1, 0.8, 0.1),
        (0.25, 0.5, 0.25),
        (0.8, 0.1, 0.1),
        (0.1, 0.1, 0.8),
        (0.5, 0.25, 0.25),
        (0.25, 0.25, 0.5)]
    points2d = [projection(p) for p in points]
    entropies = Vector{Float64}[]
    steps = Vector{Float64}[]
    for (i, p) in enumerate(points)
        push!(entropies, JLD2.load("$data_path/Purification_L=$(L)_px=$(p[1])_py=$(p[2])_pz=$(p[3])_averaging=$(averaging).jld2")["entropies"])
        push!(steps, JLD2.load("$data_path/Purification_L=$(L)_px=$(p[1])_py=$(p[2])_pz=$(p[3])_averaging=$(averaging).jld2")["steps"])
    end
    fig = Figure()
    ax = Axis(fig[1:10, 1:10], xlabel="Depth", ylabel="Entropy", title="Purification Entropy L=$L")

    insetAxis = Axis(fig[2:5, 6:10], aspect=DataAspect(), tellwidth=false, tellheight=false)
    hidedecorations!(insetAxis)
    hidespines!(insetAxis)
    lines!(insetAxis, [
            projection([1, 0, 0]),
            projection([0, 1, 0]),
            projection([0, 0, 1]),
            projection([1, 0, 0])], color=:black, joinstyle=:bevel, linewidth=1.0)
    for p in points2d
        scatter!(insetAxis, p[1], p[2], strokewidth=0.5, markersize=10)
    end
    text!(insetAxis, Point2f[projection([1.1, 0, 0]), projection([0, 1.1, 0]), projection([0, 0, 1.1])], text=[L"$$X", L"$$Y", L"$$Z"], color=:black, align=(:center, :center))

    for (step, entropy, point) in zip(steps, entropies, points)
        scatterlines!(ax, step, entropy, label="px=$(round(point[1];digits=3)), py=$(round(point[2];digits=3)), pz=$(round(point[3];digits=3))")
    end
    save("$file.svg", fig)
    save("$file.png", fig)
end
