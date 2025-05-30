struct Eagle_r3 <: Geometry
    graph::Graph

    function Eagle_r3()
        graph = SimpleGraph(126)
        g = new(graph)

        return g
    end
end
