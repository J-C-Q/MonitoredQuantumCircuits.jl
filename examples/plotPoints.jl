using CairoMakie, LinearAlgebra
using CairoMakie.GeometryBasics
function projection(point; origin=[1 / 3, 1 / 3, 1 / 3], e1=normalize(cross(normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]), normalize([1 / 3, 1 / 3, 1 / 3]))), e2=normalize([0.0, 0.0, 1.0] .- [1 / 3, 1 / 3, 1 / 3]))

    return sum(e1 .* (point .- origin)), sum(e2 .* (point .- origin))
end
function generateProbs(; N=1300)
    points = NTuple{3,Float64}[]
    n = floor(Int64, -1 / 2 + sqrt(1 / 4 + 2N))
    for (k, i) in enumerate(range(0, 1, n))
        for j in range(i, 1, n - k + 1)
            px = i
            py = j - i
            pz = 1 - j
            if px >= py - 0.01 && py >= pz - 0.01
                if px < 0.85
                    push!(points, (px, py, pz))
                end
            end
            # push!(points, (px, py, pz))
        end
    end
    return [p .- 0 .* (p .- (1 / 3, 1 / 3, 1 / 3)) for p in points]
end

points = generateProbs()

points2d = projection.(points)
ax = Axis(fig[1, 1], aspect=DataAspect())
hidedecorations!(ax)
# voronoiplot!(ax, [p[1] for p in points2d], [p[2] for p in points2d], averagedTmis, colormap=:viridis, markersize=5, strokewidth=0.5, colorrange=(-1, 1), unbounded_edge_extension_factor=1.0)
scatter!(ax, [p[1] for p in points2d], [p[2] for p in points2d])
p = Polygon(
    Point2f[(-0.8, -0.5), (0.8, -0.5), (0.8, 0.9), (-0.8, 0.9)],
    [Point2f[
        projection([1, 0, 0]),
        projection([0, 1, 0]),
        projection([0, 0, 1])
    ]]
)
poly!(p, color=:white)
lines!(ax, [
        projection([1, 0, 0]),
        projection([0, 1, 0]),
        projection([0, 0, 1]),
        projection([1, 0, 0])], color=:black)
# lines!(ax, [norm(projection([0.5, 0.5, 0])) * cos(t) for t in range(0, 2π, length=100)], [norm(projection([0.5, 0.5, 0])) * sin(t) for t in range(0, 2π, length=100)], color=:red, linewidth=2)
vlines!(ax, [0], color=:black)
lines!(ax, [projection([1.0, 0, 0]), projection([0.0, 0.5, 0.5])], color=:red, linewidth=2)
text!(ax, Point2f[projection([1.05, 0, 0]), projection([0, 1.05, 0]), projection([0, 0, 1.05])], text=["X", "Y", "Z"], color=:black, align=(:center, :center))
limits!(ax, (-0.8, 0.8), (-0.5, 0.9))
display(fig)
