
function uniqueEdgeColoring(n::Int, connectionMap::Vector{NTuple{2,Int64}})
    g = Graph(n)
    for e in connectionMap
        add_edge!(g, e[1], e[2])
    end
    lineGraph = Graph(ne(g))

    for i in 1:nv(g)
        for j in neighbors(g, i)
            for k in neighbors(g, i)
                if j < k
                    add_edge!(lineGraph, edge(g, j, i), edge(g, k, i))
                end
            end
        end
    end

    # color the line graph using graphs.jl
    coloring = Graphs.degree_greedy_color(lineGraph)
    mapBiAc(g)
end

function edge(g::Graph, u::Int, v::Int)
    edg = collect(edges(g))
    for (i, e) in enumerate(edg)
        if (src(e) == u && dst(e) == v) || (src(e) == v && dst(e) == u)
            return i
        end
    end
    return 0
end

"""
try to map the graph to a bipartite graph with acillas on the bonds
"""
function mapBiAc(g::Graph)
    siteAcillaColoring = Graphs.degree_greedy_color(g)
    if siteAcillaColoring.num_colors > 2
        println("not a bipartite graph")
        return nothing
    end
    rmAcillaGraph = deepcopy(g)
    for i in 1:nv(g)
        if siteAcillaColoring.colors[i] == 1
            rem_vertex!(rmAcillaGraph, i)
        end
    end
    return rmAcillaGraph
end
