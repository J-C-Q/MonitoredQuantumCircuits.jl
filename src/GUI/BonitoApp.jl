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
    app = App() do
        buttons = [Button("$operation", style=Styles(
            CSS("font-size" => "24px",
                "max-height" => "100px",
                "margin-top" => "20px",
                "margin-right" => "20px",
                "grid-column" => "$(i+1) / $(i+2)",
                "grid-row" => "1 / 2",),
            CSS(":hover", "background-color" => "silver"),
            CSS(":focus", "box-shadow" => "rgba(0, 0, 0, 0.5) 0px 0px 5px"),
        )) for (i, operation) in enumerate(subtypes(MonitoredQuantumCircuits.Operation))]

        plot_div = DOM.div(makie_plot(circuit, buttons), style="width: 100%; height: auto; grid-column: 1 / $(length(buttons)+2); grid-row: 1 / 2;")

        return DOM.div(
            Bonito.Grid(plot_div, buttons...,
                columns="50% repeat($(length(buttons)), 1fr)",
                rows="1fr",
                style=Styles(
                    CSS("margin" => "0px",
                        "padding" => "0px",
                        "height" => "100%"),)),
            style=Styles(
                CSS("margin" => "0px",
                    "padding" => "0px",
                    "height" => "calc(100vh - 16px)"),
            )
        )
    end
    # example_app = App(DOM.div("hello world"), title="hello world")
    # server = Bonito.Server(app, "134.95.67.139", 2000)
    app
end
function makie_plot(circuit::MonitoredQuantumCircuits.Circuit, buttons)
    lattice = circuit.lattice
    gridPositions = lattice.gridPositions
    graph = lattice.graph
    limits = (
        minimum([pos[1] for pos in gridPositions]) - 0.5,
        maximum([pos[1] for pos in gridPositions]) + 0.5,
        minimum([pos[2] for pos in gridPositions]) - 0.5,
        maximum([pos[2] for pos in gridPositions]) + 0.5,)
    WGLMakie.activate!(resize_to=:parent)
    fig = Figure()
    ax = LScene(fig[1, 1],
        show_axis=false, scenekw=(lights=[],))
    cam = Makie.Camera3D(ax.scene,
        projectiontype=Makie.Orthographic,
        eyeposition=Vec3(limits[2], (limits[4] + limits[3]) / 2, -10),
        lookat=Vec3(limits[2], (limits[4] + limits[3]) / 2, 0),
        upvector=Vec3(0, -1, 0),
        center=false)
    # aspect=:data,
    # limits=(
    #     minimum([pos[1] for pos in gridPositions]) - 0.5,
    #     2 * maximum([pos[1] for pos in lattice.gridPositions]) + 0.5,
    #     minimum([pos[2] for pos in lattice.gridPositions]) - 0.5,
    #     maximum([pos[2] for pos in lattice.gridPositions]) + 0.5,
    #     0,
    #     1),
    # perspectiveness=0,
    # elevation=π / 2,
    # azimuth=-π / 2,
    # yreversed=true,
    # viewmode=:fitzoom)
    # hidedecorations!(ax)
    # hidespines!(ax)
    connections = []
    for e in collect(edges(graph))
        src = Graphs.src(e)
        dst = Graphs.dst(e)
        push!(connections, Point3f(gridPositions[src]..., 0))
        push!(connections, Point3f(gridPositions[dst]..., 0))
    end


    linesColors = Observable([:gray for _ in 1:length(connections)])
    linesegments!(ax, connections, color=linesColors, linewidth=2)
    colors = Observable([:gray for _ in 1:length(lattice)])
    markerSize = Observable(fill(0.2, length(lattice)))

    meshscatter!(ax, Point3f.([(pos..., 0) for pos in gridPositions]), markersize=markerSize, color=colors)

    operations = subtypes(MonitoredQuantumCircuits.Operation)

    currentOperation = operations[1]
    currentColor = Observable(MonitoredQuantumCircuits.color(currentOperation()))

    gateRelation = Point3f[Point3f(i, j, -1) for (i, j) in MonitoredQuantumCircuits.plotPositions(currentOperation())]
    currentGatePositions = Observable(gateRelation)
    showOperation = Observable(false)
    linewidth = Observable(0.0)
    #1000 / (ax.finallimits[].widths[1] * ax.finallimits[].widths[2])
    meshscatter!(ax, currentGatePositions, color=currentColor, markersize=0.2, visible=true)
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
        end
    end

    # deregister_interaction!(ax, :rectanglezoom)
    # deregister_interaction!(ax, :dragpan)
    # deregister_interaction!(ax, :scrollzoom)

    on(events(fig).mousebutton, priority=1) do event
        if event.button == Mouse.left && event.action == Mouse.press

            if !isempty(selected[]) && showOperation[]
                MonitoredQuantumCircuits.apply!(circuit, currentOperation(), selected[]...)
                println(circuit)
                for pos in selected[]
                    colors[][pos] = MonitoredQuantumCircuits.color(currentOperation())
                    markerSize[][pos] = 0.2
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

    on(events(fig).keyboardbutton, priority=1) do event

        if event.action == Keyboard.press || event.action == Keyboard.repeat
            if event.key == Keyboard.a
                scrollSelect -= 1
            elseif event.key == Keyboard.d
                scrollSelect += 1
            end
            notify(events(fig).mouseposition)
            return Consume(true)
        end
        return Consume(false)
    end

    on(events(fig).mouseposition, priority=2) do event
        # println("Position = ", mouseposition(ax))
        mousePos = mouseposition(ax.scene)
        # to_world(ax, mousePos)
        # println(mousePos)
        # println(ax.finallimits[].widths[1])
        distance, index = findmin([sqrt(sum((mousePos .- point) .^ 2)) for point in lattice.gridPositions])
        if distance < 0.2
            tree, mapping = construct_tree(graph, index, MonitoredQuantumCircuits.nQubits(currentOperation()))
            possibleMappings = collect(Graphs.Experimental.all_subgraphisomorph(tree, MonitoredQuantumCircuits.connectionGraph(currentOperation()), vertex_relation=(g1, g2) -> (
                g2 != 1 ? true : mapping[g1] == index
            )))
            if !isempty(possibleMappings)
                currentGatePositions[] = [Point3f(gridPositions[mapping[n[1]]]..., 0) for n in possibleMappings[mod1(scrollSelect, length(possibleMappings))]]
                # println("selecting", mod1(scrollSelect, length(possibleMappings)), "out of", length(possibleMappings))
                notify(currentGatePositions)
                selected[] = [mapping[n[1]] for n in possibleMappings[mod1(scrollSelect, length(possibleMappings))]]
                notify(selected)
                return Consume(true)
            end
        end
        currentGatePositions[] = [Point3f(mousePos..., 0) .+ pos for pos in gateRelation]
        notify(currentGatePositions)
        empty!(selected[])
        notify(selected)
        return Consume(true)
    end
    # println(interactions(ax.scene))
    # println(WGLMakie.Observables.listeners(events(fig).mousebutton))
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
