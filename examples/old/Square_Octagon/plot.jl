using CairoMakie
using CairoMakie.GeometryBasics
using DelaunayTriangulation
using JLD2
using LinearAlgebra


function projection(point; origin=[1 / 3, 1 / 3, 1 / 3])
    e1 = normalize(cross(normalize([0.0, 0.0, 1.0] .- origin), normalize(origin)))
    e2 = normalize([0.0, 0.0, 1.0] .- origin)
    return sum(e1 .* (point .- origin)), sum(e2 .* (point .- origin))
end

function phaseDiagram(figure_name::String, data_path::String; data_point_name="probs", data_name="entropie", colorlimits=(-1, 1), set_color_limits=true)
    nan_color=:black
    # Load the data
    data_files = filter(f -> isfile(f), joinpath.(data_path, readdir(data_path)))
    n_data_points = length(data_files)
    data_points = Vector{NTuple{3,Float64}}(undef, n_data_points)
    data = Vector{Float64}(undef, n_data_points)
    println(n_data_points)
    for (i, f) in enumerate(data_files)
        data_points[i] = JLD2.load(f)[data_point_name]
        data[i] = JLD2.load(f)[data_name]
    end

    if !set_color_limits
        colorlimits = (-max(abs.(extrema(data))...), max(abs.(extrema(data))...))
        # colorlimits = extrema(data)
    end

    data_points_2D = projection.(data_points)

    fig = Figure()
    ax = Axis(fig[1, 1], aspect=DataAspect())
    hidedecorations!(ax)
    hidespines!(ax)

    colormap = to_colormap(cgrad([
        CairoMakie.RGB(165 / 255, 0 / 255, 38 / 255),
        CairoMakie.RGB(249 / 255, 152 / 255, 89 / 255),
        CairoMakie.RGB(254 / 255, 208 / 255, 130 / 255),
        CairoMakie.RGB(234 / 255, 236 / 255, 204 / 255),
        CairoMakie.RGB(131 / 255, 184 / 255, 215 / 255),
        CairoMakie.RGB(83 / 255, 134 / 255, 189 / 255),
        CairoMakie.RGB(54 / 255, 75 / 255, 154 / 255)]))

    # colormap = :devon


    triangulation = triangulate(data_points_2D)
    faces = Matrix{Int}(undef, length(each_solid_triangle(triangulation)), 3)
    for (i, t) in enumerate(each_solid_triangle(triangulation))
        faces[i, :] .= t
    end
    mesh!(ax, data_points_2D, faces, color=data, colormap=colormap, rasterize=10, colorrange=colorlimits,nan_color=nan_color)


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

    scatter!(ax, [p[1] for p in data_points_2D], [p[2] for p in data_points_2D], color=data, strokewidth=0.5, strokecolor=(:black, 0.5), colormap=colormap, markersize=5, colorrange=colorlimits,nan_color=nan_color)

    text!(ax, Point2f[projection([1.1, 0, 0]), projection([0, 1.1, 0]), projection([0, 0, 1.1])], text=[L"$$X", L"$$Y", L"$$Z"], color=:black, align=(:center, :center))

    Colorbar(fig[1, 2], limits=colorlimits, colormap=colormap,
        flipaxis=true, label=L"$$State entropy", minorticksvisible=true, minortickalign=1.0)

    save("$figure_name.svg", fig)
    save("$figure_name.png", fig)
end
