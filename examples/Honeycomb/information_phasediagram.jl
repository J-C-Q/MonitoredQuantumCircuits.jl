using CairoMakie
using CairoMakie.GeometryBasics
using DelaunayTriangulation
using JLD2
using LinearAlgebra
using AestheticSuperposition


function informationPlot(file::String, data_path::String; depth=100, L=12, averaging=10, resolution=45)
    set_theme!(AestheticSuperpositionTheme())
    points = generateProbs(n=resolution)
    tmis = Float64[]
    for (i, p) in enumerate(points)
        push!(tmis, JLD2.load("$data_path/TMI_L=$(L)_px=$(p[1])_py=$(p[2])_pz=$(p[3])_averaging=$(averaging)_depth=$depth.jld2")["tmi"])
    end
    points2d = [projection(p) for p in points]
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
    # poly!(p, color=:white)



    lines!(ax, [
            projection([1, 0, 0]),
            projection([0, 1, 0]),
            projection([0, 0, 1]),
            projection([1, 0, 0])], color=:black, joinstyle=:bevel, linewidth=1.0)

    scatter!(ax, [p[1] for p in points2d], [p[2] for p in points2d], color=tmis, strokewidth=0.5, strokecolor=(:black, 1.0), colormap=colormap, markersize=2)
    # scatter!(ax, [p[1] for p in points2d], [p[2] for p in points2d], color=:black, strokewidth=0, markersize=2)

    text!(ax, Point2f[projection([1.1, 0, 0]), projection([0, 1.1, 0]), projection([0, 0, 1.1])], text=[L"$$X", L"$$Y", L"$$Z"], color=:black, align=(:center, :center))
    # limits!(ax, (-0.8, 0.8), (-0.5, 0.9))
    Colorbar(fig[1, 2], limits=(-1, 1), colormap=colormap,
        flipaxis=true, label=L"$$Tripartite Information", minorticksvisible=true, minortickalign=1.0)

    save("$file.svg", fig)
    save("$file.png", fig)
end
