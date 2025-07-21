using CairoMakie
using JLD2
using LinearAlgebra
# using AestheticSuperposition

function entanglementPlot(file::String, data_path::String; depth=100, L=100, averaging=100, resolution=100)
    # set_theme!(AestheticSuperpositionTheme())
    points = range(0, 1, resolution)
    entropies = Float64[]
    for (i, p) in enumerate(points)
        push!(entropies, JLD2.load("$data_path/ENT_L=$(L)_p=$(p)_averaging=$(averaging)_depth=$depth.jld2")["entropy"])
    end
    fig = Figure()
    ax = Axis(fig[1, 1])
    scatterlines!(ax, points, entropies)
    save("$file.svg", fig)
    save("$file.png", fig)
    display(fig)
end
