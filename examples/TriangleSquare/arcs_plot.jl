using CairoMakie
using JLD2
using LinearAlgebra



function arcPlot(file::String, data_path::String; L=12, averaging=10,depth=100)
    points = [(1 / 3, 1 / 3, 1 / 3), (0.8, 0.1, 0.1), (0.25, 0.5, 0.25)]
    entropies = Vector{Float64}[]
    steps = 0:L
    for (i, p) in enumerate(points)
        push!(entropies, JLD2.load("$data_path/ARC_L=$(L)_px=$(p[1])_py=$(p[2])_pz=$(p[3])_averaging=$(averaging)_depth=$depth.jld2")["entanglement"])
    end
    fig = Figure()
    ax = Axis(fig[1, 1])

    for (entropy, point) in zip(entropies, points)
        lines!(ax, steps, entropy, label=point)
    end
    save("$file.svg", fig)
    save("$file.png", fig)
end
