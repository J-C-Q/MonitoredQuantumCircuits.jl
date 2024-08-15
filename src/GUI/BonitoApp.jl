module GUI
using Bonito
using Graphs
using WGLMakie
using Combinatorics
using InteractiveUtils
# import ..Lattice
# import ..Circuit
# import ..EmptyCircuit
# import ..apply!
# import ..ZZ
# import ..connectionGraph
import ...MonitoredQuantumCircuits


function CircuitComposer(lattice::MonitoredQuantumCircuits.Lattice)
    circuit = MonitoredQuantumCircuits.EmptyCircuit(lattice)
    println(subtypes(MonitoredQuantumCircuits.Operation))
    app = App() do
        buttons = [Button("$operation") for operation in subtypes(MonitoredQuantumCircuits.Operation)]

        plot_div = DOM.div(makie_plot(circuit, buttons), style="width: 50vw; height: auto; aspect-ratio: 1 / 1;")


        return DOM.div(
            Bonito.Grid(plot_div, Bonito.Grid(buttons...;); columns="50% 50%")
        )
    end
    # example_app = App(DOM.div("hello world"), title="hello world")
    # server = Bonito.Server(app, "134.95.67.139", 2000)
    app
end
function makie_plot(circuit::MonitoredQuantumCircuits.Circuit, buttons)
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
    marker = Observable(fill(:circle, length(lattice)))
    markerSize = Observable(fill(1, length(lattice)))

    p = scatter!(ax, Point2f.(lattice.gridPositions), markerspace=:data, markersize=markerSize, marker=marker, color=colors)

    operations = subtypes(MonitoredQuantumCircuits.Operation)

    currentOperation = operations[1]
    currentColor = Observable(MonitoredQuantumCircuits.color(currentOperation()))

    gateRelation = Point2f[Point2f(i, j) for (i, j) in MonitoredQuantumCircuits.plotPositions(currentOperation())]
    currentGatePositions = Observable(gateRelation)
    showOperation = Observable(false)
    linewidth = Observable(0.0)
    #1000 / (ax.finallimits[].widths[1] * ax.finallimits[].widths[2])
    lines!(ax, currentGatePositions, color=currentColor, linewidth=linewidth, visible=showOperation)
    # scatter!(ax, currentGatePositions, markersize=1, color=currentColor, markerspace=:data, visible=showOperation, marker=:rect)
    text!(ax, currentGatePositions, text=["1", "2", "3"], fontsize=16, color=:black, align=(:center, :center), visible=showOperation)

    scrollSelect = 1

    selected = Observable(Int64[])



    for (i, button) in enumerate(buttons)
        on(button.value) do click::Bool
            currentOperation = operations[i]
            currentColor[] = MonitoredQuantumCircuits.color(currentOperation())
            notify(currentColor)
            showOperation[] = true
            notify(showOperation)
            linewidth[] = (15288.35 / (ax.finallimits[].widths[1] * ax.finallimits[].widths[2])) * 0.6
            notify(linewidth)
        end
    end

    deregister_interaction!(ax, :rectanglezoom)
    deregister_interaction!(ax, :dragpan)
    deregister_interaction!(ax, :scrollzoom)

    on(events(fig).mousebutton, priority=2) do event
        if event.button == Mouse.left && event.action == Mouse.press

            if !isempty(selected[]) && showOperation[]
                apply!(circuit, currentOperation(), selected[]...)
                println(circuit)
                for pos in selected[]
                    colors[][pos] = MonitoredQuantumCircuits.color(currentOperation())
                    marker[][pos] = :rect
                    markerSize[][pos] = 1.6
                end
                notify(colors)
                notify(marker)
                notify(markerSize)
                showOperation[] = false
                notify(showOperation)
                empty!(selected[])
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

        # println(ax.finallimits[].widths[1])
        distance, index = findmin([sqrt(sum((mousePos .- point) .^ 2)) for point in lattice.gridPositions])
        if distance < 0.2
            tree, mapping = construct_tree(lattice.graph, index, MonitoredQuantumCircuits.nQubits(currentOperation()))
            possibleMappings = collect(Graphs.Experimental.all_subgraphisomorph(tree, connectionGraph(currentOperation()), vertex_relation=(g1, g2) -> (
                g2 != 1 ? true : mapping[g1] == index
            )))
            if !isempty(possibleMappings)
                currentGatePositions[] = [lattice.gridPositions[mapping[n[1]]] for n in possibleMappings[mod1(scrollSelect, length(possibleMappings))]]
                # println("selecting", mod1(scrollSelect, length(possibleMappings)), "out of", length(possibleMappings))
                notify(currentGatePositions)
                selected[] = [mapping[n[1]] for n in possibleMappings[mod1(scrollSelect, length(possibleMappings))]]
                notify(selected)
                return Consume(true)
            end
        end
        currentGatePositions[] = [Point2f(mousePos) .+ pos for pos in gateRelation]
        notify(currentGatePositions)
        empty!(selected[])
        notify(selected)
        return Consume(true)
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
