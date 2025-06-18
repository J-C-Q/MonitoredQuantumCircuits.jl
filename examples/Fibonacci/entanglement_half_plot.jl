using CairoMakie
using JLD2
using LinearAlgebra

function entanglementPlot(file::String, data_path::String; depth=100, L=100, averaging=100, resolution=100)

    # points = point_distribution(resolution; ratio_in_high_density_region=0.7, high_density_center=0.43, high_density_width=0.15)
    points = point_distribution(resolution; ratio_in_high_density_region=0.7, high_density_center=0.39, high_density_width=0.1)

    entropies = Float64[]
    for (i, p) in enumerate(points)
        push!(entropies, JLD2.load("$data_path/ENT_L=$(L)_averaging=$(averaging)_p=$(p)_depth=$depth.jld2")["entropies"][div(L,2)+1])
    end


    fig = Figure()
    ax = Axis(fig[1, 1], xlabel=L"measurement ratio $p$", ylabel=L"entanglement entropy $S_{L/2}$",
              title="Entanglement Entropy for Fibonacci Drive")

    scatterlines!(ax, points, entropies)

    vlines!(ax, [0.38196601125010515])
    save("$file.svg", fig)
    save("$file.png", fig)
    display(fig)
end

function point_distribution(n; ratio_in_high_density_region=0.5, high_density_center=0.3, high_density_width=0.1)
    d = ratio_in_high_density_region/2high_density_width
    a = high_density_center
    b = high_density_width
    equal_points = range(0, 1, n)
    f1(x) = (a-b)/(-b*d+a)*x
    f2(x) = 1/d*(x-a)+a

    f3(x) = (1-a-b)/(1-d*b-a)*(x-b*d-a)+a+b

    cross12 = (-a/d+a)/((a-b)/(-b*d+a)-1/d)
    cross23 = ((1-a-b)/(1-b*d-a)*(b*d+a)-b-a/d)/((1-a-b)/(1-d*b-a)-1/d)
    f(x) = x < cross12 ? f1(x) : x < cross23 ? f2(x) : f3(x)
    return [f(x) for x in equal_points]
end
