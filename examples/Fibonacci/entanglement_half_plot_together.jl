using CairoMakie
using JLD2
using LinearRegression
function entanglementPlotTogether(file::String, data_paths::Vector{String})

    rg = (1 + sqrt(5)) / 2
    left = 1 / (1 + rg)
    right = (1 + rg)^2 / 2rg - sqrt(((1 + rg)^2 / 2rg)^2 - (1 + rg) / rg)
    theory = 0.415712

    fig = Figure()
    grid = fig[5:10, 1:5] = GridLayout()
    grid2 = grid[1:10, 1:10] = GridLayout()
    ax = Axis(fig[1:10, 1:10],
    xlabel=L"measurement rate $p$",
    ylabel=L"entanglement entropy $S_{L/2}$",
    title=L"$$Entanglement Entropy for Fibonacci Drive",
    xtickformat=values -> [L"$%$(round(value;digits=2))$" for value in values],
    ytickformat=values -> [L"$%$(round(value;digits=2))$" for value in values],
    xgridvisible=false,
    ygridvisible=false)

    inset_ax = Axis(grid[5:9, 3:9],
    xlabel=L"$$ inverse system size $1/L$ [$10^{-3}$]",
    ylabel=L"$$peak probability",
    xtickformat=values -> [L"$%$(round(value*10^3; digits=2))$" for value in values],
    ytickformat=values -> [L"$%$(round(value;digits=2))$" for value in values],
    backgroundcolor=:white,
    xgridvisible=false,
     ygridvisible=false)





    max_x = Float64[]
    max_y = Float64[]
    for (i, data_path) in enumerate(reverse(data_paths))

        # find all files in data_path and load the data
        files = readdir(data_path, join=true)


        entanglement = Float64[]
        error = Float64[]
        probabilities = Float64[]
        system_size = 0
        for f in files
            data = JLD2.load(f)
            push!(entanglement, data["entanglement"])
            push!(error, data["error"])
            push!(probabilities, data["probability"])
            system_size = data["system_size"]
        end

        # sort the data by probability
        sorted_indices = sortperm(probabilities)
        permute!(entanglement, sorted_indices)
        permute!(error, sorted_indices)
        permute!(probabilities, sorted_indices)

        scatter!(ax, probabilities, entanglement; markersize=5, color=system_size, strokecolor=:black, strokewidth=0.5, label=L"L=%$(system_size)", colormap=:blues, colorrange=(128, 2048))

        # cubic_spline interpolation
        itp = cubic_spline(probabilities, entanglement)
        x_interp = range(left, right + 0.01, 10000)
        y_interp = itp(x_interp)


        l = system_size
        int = lines!(ax, x_interp, y_interp, color=l, colormap=:blues, colorrange=(128, 2048), label=L"L=%$(system_size)")
        max = scatter!(ax, x_interp[argmax(y_interp)], maximum(y_interp); markersize=6, strokecolor=:black, strokewidth=1, color=system_size, colormap=:blues, colorrange=(128, 2048))

        scatter!(inset_ax, 1 / l, x_interp[argmax(y_interp)]; markersize=6, strokecolor=:black, strokewidth=1, color=system_size, colormap=:blues, colorrange=(128, 2048))
        push!(max_x, 1 / l)
        push!(max_y, x_interp[argmax(y_interp)])

        translate!(int, 0,0,1/l+0.001)
        translate!(max, 0, 0, 1 / l + 0.002)


    end

    fit = linregress(max_x[1:3], max_y[1:3])
    xs = range(0, 1 / 128, 1000)
    lines!(inset_ax, xs, LinearRegression.slope(fit) .* xs .+ LinearRegression.bias(fit), color=:gray)


    l1 = vlines!(ax, [left], color=:orange)
    l2 = vlines!(ax, [LinearRegression.bias(fit)], color=:red)
    l3 = vlines!(ax, [right], color=:black)
    l4 = vlines!(ax, [theory], color=:black, linestyle=:dot)

    hlines!(inset_ax, [left], color=:orange)
    hlines!(inset_ax, [LinearRegression.bias(fit)], color=:red)
    hlines!(inset_ax, [right], color=:black)
    hlines!(inset_ax, [theory], color=:black, linestyle=:dot)




    axislegend(ax, L"system size $L$", position=:rt, merge=true, unique=true)
    axislegend(ax, [l1, l2, l3, l4], [L"golden ratio $1/(1+\phi)$", L"$$numerical extrapolation", L"$$theoretical value", L"$$corrected theory"], position=:lt)
    # limits!(ax, 0, 1, 0, nothing)
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
    # sitp = Spline1D(xs, ys; w=ones(length(xs)), k=3, bc="nearest", s=0.0)
    sitp = Spline1D(xs, ys, xs[2:5:end-1]; w=ones(length(xs)), k=3, bc="nearest")
    return sitp
end



"""
    get_BBox(ax;
        margin = (7.0, 7.0, 7.0, 7.0),
        position = :rt,
        width = 100,
        height = 100,
        kwargs...)
This function returns a BBox object which can be used to place a new axis.
"""
function get_BBox(ax;
    position=:rt,
    width=100,
    height=100,
    kwargs...)
    margin = kwargs[:margin]
    # haskey(kwargs, :margin) ? margin = kwargs[:margin] : margin = ax.blockscene.theme[:Legend][:margin][]

    ax_bbox = ax.layoutobservables.computedbbox[]
    l = left(ax_bbox) + margin[1]
    r = right(ax_bbox) - margin[2]
    b = bottom(ax_bbox) + margin[3]
    t = top(ax_bbox) - margin[4]

    # if legend is given update l or r
    if haskey(kwargs, :legend)
        legend = kwargs[:legend]
        leg_bbox = leg.layoutobservables.computedbbox[]

        if MakieLayout.center(leg_bbox)[1] > MakieLayout.center(ax_bbox)[1]
            r = left(leg_bbox) + legend.margin[][1] - margin[2]
        else
            l = right(leg_bbox) - legend.margin[][2] + margin[1]
        end
    end

    occursin("l", (position |> string)) && (r = l + width)
    occursin("r", (position |> string)) && (l = r - width)
    occursin("b", (position |> string)) && (t = b + height)
    occursin("t", (position |> string)) && (b = t - height)

    BBox(l, r, b, t)
end
