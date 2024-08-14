module GUI
using Bonito
using Graphs
using WGLMakie
using Combinatorics

import ..Lattice
import ..Circuit
import ..EmptyCircuit
import ..apply!
import ..ZZ
import ..connectionGraph

function CircuitComposer(lattice::Lattice)
    circuit = EmptyCircuit(lattice)
    app = App() do
        plot_div = DOM.div(makie_plot(circuit), style="width: 50vw; height: auto; aspect-ratio: 1 / 1;")

        return DOM.div(
            plot_div
        )
    end
    # example_app = App(DOM.div("hello world"), title="hello world")
    # server = Bonito.Server(app, "134.95.67.139", 2000)
    app
end
function makie_plot(circuit::Circuit)
    lattice = circuit.lattice
    WGLMakie.activate!(resize_to=:parent)
    fig = Figure()
    ax = Axis(fig[1, 1], aspect=DataAspect())
    ax.yreversed = true
    hidedecorations!(ax)
    hidespines!(ax)
    connections = []
    for e in collect(edges(lattice.graph))
        src = Graphs.src(e)
        dst = Graphs.dst(e)
        push!(connections, Point2f(lattice.gridPositions[src]))
        push!(connections, Point2f(lattice.gridPositions[dst]))
    end
    linesColors = Observable([:gray for _ in 1:length(connections)])
    linesegments!(ax, connections, color=linesColors, linewidth=2)
    colors = Observable([:gray for _ in 1:length(lattice)])

    p = scatter!(ax, Point2f.(lattice.gridPositions), markerspace=:data, markersize=0.8, color=colors)

    gateRelation = Point2f[Point2f(-1, 0), Point2f(0, 0), Point2f(1, 0)]
    currentGatePositions = Observable(gateRelation)
    lines!(ax, currentGatePositions, color=:red, linewidth=2)
    scatter!(ax, currentGatePositions, markersize=0.8, color=:red, markerspace=:data, strokecolor=:black, strokewidth=3)
    text!(ax, currentGatePositions, text=["1", "2", "3"], fontsize=16, color=:black, align=(:center, :center))

    scrollSelect = 1

    selected = Observable(Int64[])



    deregister_interaction!(ax, :rectanglezoom)
    deregister_interaction!(ax, :dragpan)
    deregister_interaction!(ax, :scrollzoom)

    on(events(fig).mousebutton, priority=2) do event
        if event.button == Mouse.left && event.action == Mouse.press

            if !isempty(selected[])
                apply!(circuit, ZZ(), selected[]...)
                println(circuit)
                notify(colors)
                return Consume(true)
            end


        end
        return Consume(false)
    end

    on(events(fig).scroll, priority=2) do (dx, dy)
        scrollSelect += Int(sign(dy))
        notify(events(fig).mouseposition)
        return Consume(true)
    end

    on(events(fig).mouseposition, priority=2) do event
        # println("Position = ", mouseposition(ax))
        mousePos = mouseposition(ax)

        distances = [sqrt(sum((mousePos .- point) .^ 2)) for point in lattice.gridPositions]
        perm = sortperm(distances)

        tree, mapping = construct_tree(lattice.graph, perm[1], 1)
        possibleMappings = collect(Graphs.Experimental.all_subgraphisomorph(tree, connectionGraph(ZZ()), vertex_relation=(g1, g2) -> (
            if g2 == 1 || g2 == 3
                return true
            elseif g2 == 2
                return mapping[g1] == perm[1]
            else
                return false
            end
        )))
        if !isempty(possibleMappings)
            currentGatePositions[] = [lattice.gridPositions[mapping[n[1]]] for n in possibleMappings[mod1(scrollSelect, length(possibleMappings))]]
            # println("selecting", mod1(scrollSelect, length(possibleMappings)), "out of", length(possibleMappings))
            notify(currentGatePositions)
            selected[] = [mapping[n[1]] for n in possibleMappings[mod1(scrollSelect, length(possibleMappings))]]
            notify(selected)
            return Consume(true)
        else
            currentGatePositions[] = [Point2f(mousePos) .+ pos for pos in gateRelation]
            notify(currentGatePositions)
            empty!(selected[])
            notify(selected)
            return Consume(true)

        end
        return Consume(false)
    end

    # println(interactions(ax))
    fig
end

function construct_tree(graph::Graph, start_node::Integer, max_depth::Integer)
    tree = SimpleGraph(nv(graph))  # Create an empty graph with the same number of vertices
    visited = Set{Int}()
    stack = [(start_node, 0)]  # Stack of (node, depth)

    while !isempty(stack)
        node, depth = pop!(stack)
        if depth < max_depth && !(node in visited)
            push!(visited, node)
            for neighbor in neighbors(graph, node)
                if !(neighbor in visited)
                    add_edge!(tree, node, neighbor)
                    push!(stack, (neighbor, depth + 1))
                end
            end
        end
    end

    # Collect all vertices with zero degree
    vertices_to_remove = [v for v in vertices(tree) if degree(tree, v) == 0]

    mapping = rem_vertices!(tree, vertices_to_remove)

    return tree, mapping
end
end
