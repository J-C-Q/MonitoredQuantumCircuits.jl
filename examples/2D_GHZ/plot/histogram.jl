using CairoMakie
theme = Theme(
    figure_padding=7,
    size=(246, 3/4*246),
    fontsize=8,
    Scatter=(
        markersize=2.0,
        strokewidth=0.0,
        marker=:circle,
        strokecolor=(:black, 0.5),
    ),
    Lines=(
        linewidth=1.0,
    ),
    VLines=(
        linewidth=1.0,
    ),
    Errorbars=(
        linewidth=0.35,
        whiskerwidth=2.0,
        color=:black,
    ),
    Axis=(
        titlefont=:regular,
        titlesize=10,
        xlabelsize=10,
        ylabelsize=10,
        xgridvisible=false,
        ygridvisible=false,
        xticksize=2.5,
        yticksize=2.5,
        xminorticksize=1.5,
        yminorticksize=1.5,
        spinewidth=0.75,
        xtickwidth=0.75,
        ytickwidth=0.75,
        xminortickwidth=0.75,
        yminortickwidth=0.75,
        xticksmirrored = true,
        yticksmirrored = true,
        xtickalign=1,
        ytickalign=1,
        xminortickalign=1,
        yminortickalign=1,
        xminorticksvisible=true,
        yminorticksvisible=true,

    ),
    Legend=(
        labelfont=:regular,
        padding=(2, 2, 2, 2), # The additional space between the legend content and the border.
        patchlabelgap=3, # The gap between the patch and the label of each legend entry.
        patchsize=(4, 4), # The size of the rectangles containing the legend markers.
        rowgap=0, # The gap between the entry rows.
        colgap=0, # The gap between the entry columns.
        titlefont=:regular,
        titlegap=1,
        margin=(2, 2, 2, 2),
        framevisible=false,
    ),
)
# merge the theme with the theme_latexfonts() and update the theme
theme = merge(theme, theme_latexfonts())
update_theme!(theme)


function plot_magnetization(data; title="magnetization_histogram")
    fig = Figure()
    ax = Axis(fig[1, 1], xlabel="magnetization", ylabel="relative counts",xticks=(-12:4:12),xminorticks=IntervalsBetween(4),yminorticks=IntervalsBetween(10))

    bars = -10:10
    hist_data = [sum(data .== b)/length(data) for b in bars]

    barplot!(ax, bars, hist_data, color=:orange, strokecolor=:black, strokewidth=0.5)
    # density!(ax, data, color=:orange, strokecolor=:black, strokewidth=0.5,strokearound = true,boundary=(-15,15), bandwidth=1.3)

    # hist!(ax, data, color=:orange, strokecolor=:black, strokewidth=0.5, bins=21, normalization=:pdf)

    # hidedecorations!(ax)
    filename = title
    limits!(ax, -13,13,0,nothing)
    save("figures/$filename.svg", fig)
    save("figures/$filename.png", fig)
    save("figures/$filename.pdf", fig)
    return fig
end
