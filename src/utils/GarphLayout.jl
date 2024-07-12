module GraphLayout
using Random
using NetworkLayout

function gridLayout(g::Graph, Lx::Integer, Ly::Integer)
    # Perform monte carlo simulated annealing to find a good layout
    grid = zeros(Int64, Lx, Ly)

    # create random configuration
    girdPoints = [(i, j) for i in 1:Lx, j in 1:Ly]
    shuffle!(girdPoints)
    for vertex in 1:nv(g)
        grid[girdPoints[vertex]...] = vertex
    end

    # compute energy





end

end
