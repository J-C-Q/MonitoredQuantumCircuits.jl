using LinearRegression
function entanglementPlotPeaks(file::String, data_path::String; depths=[100], Ls=[100], averagings=[100], resolutions=[24])




    fig = Figure()
    ax = Axis(fig[1, 1], xlabel=L"$1/L$", ylabel=L"$$peak probability",
        title=L"$$Entanglement Entropy for Fibonacci Drive, depth=%$(depths[1])",)

    hlines!(ax, [0.38196601125010515], color=:orange)
    data_xs = Float64[]
    data_ys = Float64[]
    for (d, l, a, resolution) in zip(depths, Ls, averagings, resolutions)
        points = point_distribution(resolution; ratio_in_high_density_region=0.7, high_density_center=0.43, high_density_width=0.15)

        entropies = Float64[]
        for (i, p) in enumerate(points)
            push!(entropies, JLD2.load("$data_path/ENT_L=$(l)_averaging=$(a)_p=$(p)_depth=$(d).jld2")["entropies"][div(l, 2)+1])
        end
        # scatterlines!(ax, points, entropies, color=l, colormap=:blues, colorrange=(32, 512), label=L"%$l")

        # cubic_spline interpolation
        itp = cubic_spline(points, entropies)
        x_interp = range(0, 1, 10000)
        y_interp = itp(x_interp)

        push!(data_xs, 1 / l)
        push!(data_ys, x_interp[argmax(y_interp)])


    end


    # fit = linregress(data_xs[end-2:end], data_ys[end-2:end])
    # fit = linregress(data_xs, data_ys)
    fit = linregress(data_xs[end-3:end], data_ys[end-3:end])

    xs = range(0, 1 / minimum(Ls), 1000)
    lines!(ax, xs, LinearRegression.slope(fit) .* xs .+ LinearRegression.bias(fit), color=:black)
    hlines!(ax, [LinearRegression.bias(fit)], color=:orange)


    text!(ax, [0.01], [LinearRegression.bias(fit)], text=L"$$linear fit intercept=%$(LinearRegression.bias(fit))", color=:orange)

    text!(ax, [0.02], [0.38196601125010515], text=L"$$golden ratio", color=:orange)


    scatter!(ax, data_xs, data_ys, color=1.0 ./ data_xs, colormap=:reds, colorrange=(32, 1024))

    limits!(ax, 0, nothing,nothing,nothing)
    # axislegend(ax, L"system size $L$", position=:lb,)
    save("$file.svg", fig)
    save("$file.png", fig)
    save("$file.pdf", fig)
    display(fig)
end

using Dierckx
function cubic_spline(x::AbstractVector{<:Real},
    y::AbstractVector{<:Real})

    length(x) == length(y) ||
        throw(ArgumentError("x and y must have the same length"))

    # Ensure the nodes are strictly increasing
    idx = sortperm(x)
    xs = collect(Float64, x[idx])   # force concrete arrays
    ys = collect(Float64, y[idx])

    # sitp = Spline1D(xs, ys, xs[5:2:end-12]; w=ones(length(xs)), k=3, bc="nearest")
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
