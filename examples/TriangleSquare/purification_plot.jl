using CairoMakie
using JLD2
using LinearAlgebra



function purificationPlot(file::String, data_path::String; L=12, averaging=10)
    points = [(1 / 3, 1 / 3, 1 / 3), (0.8, 0.1, 0.1), (0.25, 0.5, 0.25)]
    entropies = Vector{Float64}[]
    steps = Vector{Int64}[]
    for (i, p) in enumerate(points)
        push!(entropies, JLD2.load("$data_path/Purification_L=$(L)_px=$(p[1])_py=$(p[2])_pz=$(p[3])_averaging=$(averaging).jld2")["entropies"])
        push!(steps, JLD2.load("$data_path/Purification_L=$(L)_px=$(p[1])_py=$(p[2])_pz=$(p[3])_averaging=$(averaging).jld2")["steps"])
    end
    fig = Figure()
    ax = Axis(fig[1, 1])

    for (step, entropy, point) in zip(steps, entropies, points)
        println(entropy)
        lines!(ax, step, entropy, color=:black, label=point)
    end
    save("$file.svg", fig)
    save("$file.png", fig)
end
