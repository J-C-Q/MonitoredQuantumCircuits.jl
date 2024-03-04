function uniqueEdgeColoring(n::Int, connectionMap::Vector{NTuple{2,Int64}})
    g = Graph(n)
    for e in connectionMap
        add_edge!(g, e[1], e[2])
    end
    lineGraph = Graph(ne(g))

    # create a line graph coresponding to gate


end
