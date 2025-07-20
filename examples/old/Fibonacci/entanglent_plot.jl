using CairoMakie
using JLD2
using LinearAlgebra

function entanglementPlot(file::String, data_path::String; depth=100, L=100, averaging=100, resolution=100)

    points = range(0, 1, resolution)
    entropies = Vector{Float64}[]
    for (i, p) in enumerate(points)
        push!(entropies, JLD2.load("$data_path/ENT_L=$(L)_averaging=$(averaging)_p=$(p)_depth=$depth.jld2")["entropies"])
    end


    fig = Figure()
    ax = Axis(fig[1, 1], xlabel=L"subsystem size $l$", ylabel=L"entanglement entropy $S_l$",
              title="Entanglement Entropy for Fibonacci Drive")
    for (i,e) in enumerate(entropies)
        scatterlines!(ax, 0:L, e, label="p=$(round(points[i], digits=2))", color = 1-points[i], colormap = :blues, colorrange = (0,1))
    end
    axislegend(ax)
    save("$file.svg", fig)
    save("$file.png", fig)
    display(fig)
end
