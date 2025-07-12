using CairoMakie
using JLD2
using LinearAlgebra

function entanglementPlot(file::String, data_path::String;)

    rg = (1+sqrt(5))/2
    left = 1/(1+rg)
    right = (1+rg)^2/2rg - sqrt(((1+rg)^2/2rg)^2 - (1+rg)/rg)

    # find all files in data_path and load the data
    files = readdir(data_path, join=true)


    entanglement = Float64[]
    error = Float64[]
    probabilities = Float64[]
    for f in files
        data = JLD2.load(f)
        if haskey(data, "entanglement")
            push!(entanglement, data["entanglement"])
            push!(error, data["error"])
            push!(probabilities, data["probability"])
        end
    end

    # sort the data by probability
    sorted_indices = sortperm(probabilities)
    permute!(entanglement, sorted_indices)
    permute!(error, sorted_indices)
    permute!(probabilities, sorted_indices)


    fig = Figure()
    ax = Axis(fig[1, 1], xlabel=L"measurement rate $p$", ylabel=L"entanglement entropy $S_{L/2}$",
              title="Entanglement Entropy for Fibonacci Drive")

    scatter!(ax, probabilities, entanglement;  markersize=2, color=:white, strokecolor=:black, strokewidth=0.5)

    vlines!(ax, [left, right])

    limits!(ax, 0,1,0,nothing)
    save("$file.svg", fig)
    save("$file.png", fig)
    display(fig)
end
