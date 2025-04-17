using CairoMakie
using JLD2
using LinearAlgebra

function projection(point; origin=[1 / 3, 1 / 3, 1 / 3], e1=normalize(cross(normalize([0.0, 0.0, 1.0] .- origin), normalize(origin))), e2=normalize([0.0, 0.0, 1.0] .- origin))

    return sum(e1 .* (point .- origin)), sum(e2 .* (point .- origin))
end

function arcPlot(file::String, data_path::String; L=12, averaging=10,depth=100)
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
    steps = 0:L
    for (i, p) in enumerate(points)
        push!(entropies, JLD2.load("$data_path/ARC_L=$(L)_px=$(p[1])_py=$(p[2])_pz=$(p[3])_averaging=$(averaging)_depth=$depth.jld2")["entanglement"])
    end
    fig = Figure()
    ax = Axis(fig[1:10, 1:10], xlabel="Subsystem size", ylabel="Entropy", title="Entanglement Entropy L=$L")
    insetAxis = Axis(fig[1:4, 1:3], aspect=DataAspect(), tellwidth=false, tellheight=false)
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



    for (entropy, point) in zip(entropies, points)
        scatterlines!(ax, steps, entropy, label="px=$(round(point[1];digits=3)), py=$(round(point[2];digits=3)), pz=$(round(point[3];digits=3))")
    end
    # axislegend(ax, position=:rt)
    save("$file.svg", fig)
    save("$file.png", fig)
end
