using HDF5
using CairoMakie
using CairoMakie.GeometryBasics
using DelaunayTriangulation
using MonitoredQuantumCircuits
using LinearAlgebra
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

function average_data(f)
    tmi = read(f["tmi"])
    n_samples = read(f["averaging"])

    averaged_tmi = sum(tmi, dims=1) ./ n_samples
    f["tmi_averaged"] = averaged_tmi
    return nothing
end

function projection(point; origin=[1 / 3, 1 / 3, 1 / 3], e1=normalize(cross(normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]), normalize([1 / 3, 1 / 3, 1 / 3]))), e2=normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]))

    return sum(e1 .* (point .- origin)), sum(e2 .* (point .- origin))
end
function plot_phasediagram(file)
    f = file
    L = read(f["L"])
    depth = read(f["depth"])

    averaging = read(f["averaging"])
    type = read(f["type"])
    tmis = vec(read(f["tmi_averaged"]))
    points = read(f["probabilities"])
    n = length(points)
    points2d = [projection(p) for p in eachcol(points)]

    fig = Figure()
    ax = Axis(fig[1, 1], aspect=DataAspect())
    hidedecorations!(ax)
    hidespines!(ax)

    colormap = Reverse(:vik)
    colormap = to_colormap(cgrad([
        CairoMakie.RGB(165 / 255, 0 / 255, 38 / 255),
        CairoMakie.RGB(249 / 255, 152 / 255, 89 / 255),
        CairoMakie.RGB(254 / 255, 208 / 255, 130 / 255),
        CairoMakie.RGB(234 / 255, 236 / 255, 204 / 255),
        # CairoMakie.RGB(0, 0, 0),
        CairoMakie.RGB(131 / 255, 184 / 255, 215 / 255),
        CairoMakie.RGB(83 / 255, 134 / 255, 189 / 255),
        CairoMakie.RGB(54 / 255, 75 / 255, 154 / 255)]))



    # voronoiplot!(ax, [p[1] for p in points2d], [p[2] for p in points2d], averagedTmis, colormap=:vik10, markersize=5, strokewidth=0.0, show_generators=false, smooth=false, unbounded_edge_extension_factor=1.0, colorrange=(-1, 1), highclip=:white, lowclip=:white, nan_color=:black)
    #
    # tricontourf!(ax, [p[1] for p in points2d], [p[2] for p in points2d], averagedTmis, colormap=:vik10, levels=5)
    tri = triangulate(points2d)
    faces = Matrix{Int}(undef, length(each_solid_triangle(tri)), 3)
    for (i, t) in enumerate(each_solid_triangle(tri))
        faces[i, :] .= t
    end
    mesh!(ax, points2d, faces, color=tmis, colormap=colormap, rasterize=10)


    p = Polygon(
        Point2f[(-0.8, -0.5), (0.8, -0.5), (0.8, 0.9), (-0.8, 0.9)],
        [Point2f[
            projection([1, 0, 0]),
            projection([0, 1, 0]),
            projection([0, 0, 1])
        ]]
    )


    # scatter!(ax, [p[1] for p in points2d], [p[2] for p in points2d], color=:black, strokewidth=0, markersize=5)
    scatter!(ax, [p[1] for p in points2d], [p[2] for p in points2d], color=tmis, strokewidth=0.25, strokecolor=:black, colormap=colormap, markersize=2)
   poly!(p, color=:white)
    lines!(ax, [
            projection([1, 0, 0]),
            projection([0, 1, 0]),
            projection([0, 0, 1]),
            projection([1, 0, 0])], color=:black, joinstyle=:bevel, linewidth=0.75)




    text!(ax, Point2f[projection([1.1, 0, 0]), projection([0, 1.1, 0]), projection([0, 0, 1.1])], text=[L"$p_X$", L"$p_Y$", L"$p_Z$"], color=:black, align=(:center, :center),fontsize=8)
    # limits!(ax, (-0.8, 0.8), (-0.5, 0.9))
    Colorbar(fig[1, 2], limits=(minimum(tmis), maximum(tmis)), colormap=colormap,
        flipaxis=true, label=L"$$Tripartite Information", minorticksvisible=true, minortickalign=1.0,tickalign=1.0,spinewidth=0.75,minortickwidth=0.75,tickwidth=0.75,height=154, tellheight=false)
    limits!(ax, (-0.82, 0.82), (-0.515, 0.915))
    filename = "honeycomb_circuit_L$(L)_D$(depth)_pres$(n)_avg$(averaging)_$(type)"
    save("figures/$filename.svg", fig)
    save("figures/$filename.png", fig)
    save("figures/$filename.pdf", fig)
end
