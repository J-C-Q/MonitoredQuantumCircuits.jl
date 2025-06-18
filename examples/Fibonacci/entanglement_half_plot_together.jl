function entanglementPlotTogether(file::String, data_path::String; depths=[100], Ls=[100], averagings=[100], resolutions=[24])

    # points = point_distribution(resolution; ratio_in_high_density_region=0.7, high_density_center=0.43, high_density_width=0.15)



    fig = Figure()
    ax = Axis(fig[1, 1], xlabel=L"measurement rate $p$", ylabel=L"entanglement entropy $S_{L/2}$",
        title=L"$$Entanglement Entropy for Fibonacci Drive, depth=%$(depths[1])",)


    l1 = vlines!(ax, [0.38196601125010515], color=:orange)
    l2 = vlines!(ax, [0.41279780151928236], color=:red)
    l3 =vlines!(ax, [0.4245069034188409], color=:black)
    for (d, l, a, resolution) in reverse(collect(zip(depths, Ls, averagings, resolutions)))
        points = point_distribution(resolution; ratio_in_high_density_region=0.7, high_density_center=0.43, high_density_width=0.15)

        entropies = Float64[]
        for (i, p) in enumerate(points)
            push!(entropies, JLD2.load("$data_path/ENT_L=$(l)_averaging=$(a)_p=$(p)_depth=$(d).jld2")["entropies"][div(l, 2)+1])
        end
        plot = scatterlines!(ax, points, entropies, color=l, colormap=:blues, colorrange=(32, 1024), label=L"%$l")
        translate!(plot, 0,0,1/l)

        # cubic_spline interpolation
        itp = cubic_spline(points, entropies; bc=:flat)
        x_interp = range(0, 1, 10000)
        y_interp = itp(x_interp)


        int = lines!(ax, x_interp, y_interp, color=l, colormap=:reds, colorrange=(32, 1024))
        translate!(int, 0,0,1/l+0.001)

    end
    # text!(ax, [0.38196601125010515], [0.5], text=L"$$golden ratio", color=:orange, rotation=pi / 2)

    axislegend(ax, L"system size $L$", position=:rt,)
    axislegend(ax, [l1,l2,l3], [L"golden ratio $1/(1+\phi)$", L"$$numerical extrapolation", L"$$theoretical value"], position = :lb)
    save("$file.svg", fig)
    save("$file.png", fig)
    save("$file.pdf", fig)
    display(fig)
end

using Dierckx
function cubic_spline(x::AbstractVector{<:Real},
    y::AbstractVector{<:Real};
    bc::Symbol=:flat)

    length(x) == length(y) ||
        throw(ArgumentError("x and y must have the same length"))

    # Ensure the nodes are strictly increasing
    idx = sortperm(x)
    xs = collect(Float64, x[idx])   # force concrete arrays
    ys = collect(Float64, y[idx])

    sitp = Spline1D(xs, ys; w=ones(length(xs)), k=3, bc="nearest", s=0.0)
    return sitp
end

function point_distribution(n; ratio_in_high_density_region=0.5, high_density_center=0.3, high_density_width=0.1)
    d = ratio_in_high_density_region / 2high_density_width
    a = high_density_center
    b = high_density_width
    equal_points = range(0, 1, n)
    f1(x) = (a - b) / (-b * d + a) * x
    f2(x) = 1 / d * (x - a) + a

    f3(x) = (1 - a - b) / (1 - d * b - a) * (x - b * d - a) + a + b

    cross12 = (-a / d + a) / ((a - b) / (-b * d + a) - 1 / d)
    cross23 = ((1 - a - b) / (1 - b * d - a) * (b * d + a) - b - a / d) / ((1 - a - b) / (1 - d * b - a) - 1 / d)
    f(x) = x < cross12 ? f1(x) : x < cross23 ? f2(x) : f3(x)
    return [f(x) for x in equal_points]
end
