module GUI
using Bonito
using Graphs
using WGLMakie
using Combinatorics
using InteractiveUtils
using FileIO
# import ..Lattice
# import ..Circuit
# import ..EmptyCircuit
# import ..apply!
# import ..ZZ
# import ..connectionGraph
import ...MonitoredQuantumCircuits


function CircuitComposer!(circuit::MonitoredQuantumCircuits.Circuit)
    # circuit = MonitoredQuantumCircuits.EmptyCircuit(lattice)
    app = App() do
        buttons = [Button("$operation", style=Styles(
            CSS("font-size" => "24px",
                "max-height" => "100px",
                "margin-top" => "20px",
                "margin-right" => "20px",
                "grid-column" => "$(i+1) / $(i+2)",
                "grid-row" => "1 / 2",
                "backgraound-color" => "white",
                "border" => "0px solid white",),
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
    return app
end
function makie_plot(circuit::MonitoredQuantumCircuits.Circuit, buttons)
    lattice = circuit.lattice
    gridPositions = lattice.gridPositions
    graph = lattice.graph
    allOperations = subtypes(MonitoredQuantumCircuits.Operation)
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
        eyeposition=Vec3((limits[2] + limits[1]) / 2, (limits[4] + limits[3]) / 2, -max(abs(limits[2] - limits[1]), abs(limits[4] - limits[3])) * 1),
        lookat=Vec3((limits[2] + limits[1]) / 2, (limits[4] + limits[3]) / 2, 0),
        upvector=Vec3(0, -1, 0),
        center=false,
        cad=false,)
    # zoom!(ax.scene, 0.6)
    # update_cam!(ax.scene, Vec3(limits[2], limits[4], -max(abs(limits[2] - limits[1]), abs(limits[4] - limits[3])) * 0.3), Vec3(limits[2], (limits[4] + limits[3]) / 2, 0), Vec3(0, -1, 0))

    begin #! Graph plot
        connections = []
        for e in collect(edges(graph))
            src = Graphs.src(e)
            dst = Graphs.dst(e)
            push!(connections, Point3f(gridPositions[src]..., 0))
            push!(connections, Point3f(gridPositions[dst]..., 0))
        end
        linesegments!(ax,
            connections,
            color=:gray,
            linewidth=2)
        meshscatter!(ax,
            Point3f.([(pos..., 0) for pos in gridPositions]),
            markersize=0.2,
            color=:gray)
    end

    begin #! select plot
        selectorOperation = allOperations[1]
        selectorColor = Observable(MonitoredQuantumCircuits.color(selectorOperation()))
        selectorLabels = ["$i" for i in 1:MonitoredQuantumCircuits.nQubits(selectorOperation())]
        scrollSelect = 1

        gateRelation = Point3f[Point3f(i, j, -1) for (i, j) in MonitoredQuantumCircuits.plotPositions(selectorOperation())]
        selectorPositions = Observable(gateRelation)
        showSelector = Observable(false)

        lines!(ax,
            selectorPositions,
            linewidth=4,
            color=:black,
            visible=showSelector)
        meshscatter!(ax,
            selectorPositions,
            color=selectorColor,
            markersize=0.2,
            visible=showSelector)

        # text!(ax,
        #     selectorPositions,
        #     text=selectorLabels,
        #     markerspace=:data,
        #     fontsize=0.1,
        #     rotation=π,
        #     transform_marker=true,
        #     color=:black,
        #     align=(:center, :center),
        #     visible=showSelector)
    end

    begin #! circuit plot
        gatePositions = Observable(Point3f[])
        gateConnections = Observable(Point3f[])
        gateConnectionColors = Observable(Symbol[])
        gateConnectionRotations = Observable(Vec3f[])
        gateConnectionScale = Observable(Vec3f[])
        gateColors = Observable(Symbol[])
        currentHeight = -0.4
        currentHeights = zeros(Float32, length(lattice))
        for exec in sort(unique(circuit.executionOrder))
            ops = MonitoredQuantumCircuits._getOperations(circuit, exec)
            operations = [circuit.operationPositions[operation] for operation in ops]
            height = -0.4 * exec
            currentHeight = height
            for (i, pos) in enumerate(operations)
                for p in pos
                    push!(gateColors[], MonitoredQuantumCircuits.color(circuit.operations[circuit.operationPointers[ops[i]]]))
                    push!(gatePositions[], Point3f(gridPositions[p]..., height))



                    currentHeights[p] = height


                end
                for (i, p) in enumerate(pos[1:end-1])
                    push!(gateConnections[], Point3f(((gridPositions[p] .+ gridPositions[pos[i+1]]) ./ 2)..., height))
                    push!(gateConnectionRotations[], Vec3f(((gridPositions[pos[i+1]] .- gridPositions[p]))..., 0))
                    push!(gateConnectionScale[], Vec3f(0.2, 0.2, sqrt(sum((gridPositions[pos[i+1]] .- gridPositions[p]) .^ 2))))
                    push!(gateConnectionColors[], MonitoredQuantumCircuits.color(circuit.operations[circuit.operationPointers[ops[i]]]))
                end
                # push!(gateConnectionColors[], :transparent)
                # push!(gateConnectionColors[], :transparent)
                # push!(gateConnections[], Point3f(NaN))
                notify(gateConnectionRotations)
                notify(gateConnections)
                notify(gatePositions)
                notify(gateColors)
                notify(gateConnectionColors)
            end
        end

        meshscatter!(ax,
            gatePositions,
            markersize=0.2,
            color=:black)
        meshscatter!(ax,
            gateConnections,
            color=gateConnectionColors,
            marker=load("src/GUI/meshes/cylinder.stl"),
            markersize=gateConnectionScale,
            rotation=gateConnectionRotations)
        # lines!(ax,
        #     gateConnections,
        #     linewidth=4,
        #     color=gateConnectionColors)
    end


    selected = Observable(Int64[])
    movable = true


    for (i, button) in enumerate(buttons)
        on(button.value) do click::Bool
            movable = false
            update_cam!(ax.scene, Vec3((limits[2] + limits[1]) / 2, (limits[4] + limits[3]) / 2, -max(abs(limits[2] - limits[1]), abs(limits[4] - limits[3])) * 1), Vec3((limits[2] + limits[1]) / 2, (limits[4] + limits[3]) / 2, 0), Vec3(0, -1, 0))
            selectorOperation = allOperations[i]
            selectorColor[] = MonitoredQuantumCircuits.color(selectorOperation())
            showSelector[] = true
            notify(selectorColor)
            notify(showSelector)
        end
    end

    on(events(fig).mousebutton, priority=2) do event
        if event.button == Mouse.left && event.action == Mouse.press
            if movable
                return Consume(false)
            end
            if !isempty(selected[]) && showSelector[]
                MonitoredQuantumCircuits.apply!(circuit, selectorOperation(), selected[]...)
                println(circuit)
                height = minimum([currentHeights[i] for i in selected[]])
                if height == currentHeight
                    currentHeight -= 0.4
                end
                height -= 0.4
                for pos in selected[]
                    push!(gateColors[], MonitoredQuantumCircuits.color(selectorOperation()))
                    push!(gatePositions[], Point3f(gridPositions[pos]..., height))
                    currentHeights[pos] = height
                    push!(gateConnections[], Point3f(gridPositions[pos]..., height))
                end
                push!(gateConnections[], Point3f(NaN))
                notify(gateConnections)
                notify(gatePositions)
                notify(gateColors)

                # showSelector[] = false
                # notify(showSelector)
                empty!(selected[])
                return Consume(true)
            else
                showSelector[] = false
                notify(showSelector)
                return Consume(true)
            end
        elseif event.button == Mouse.right && event.action == Mouse.press

            scrollSelect += 1
            notify(events(fig).mouseposition)
            return Consume(true)
        end
        return Consume(true)
    end

    on(events(fig).scroll, priority=1) do (dx, dy)
        if movable
            return Consume(false)
        end
        scrollSelect += Int(sign(dy))
        notify(events(fig).mouseposition)
        return Consume(true)
    end

    on(events(fig).keyboardbutton, priority=1) do event
        return Consume(true)
    end

    on(events(fig).mouseposition, priority=1) do event
        if movable
            return Consume(false)
        end
        if !showSelector[]
            mousePos = mouseposition(ax.scene)
            selectorPositions[] = [Point3f(mousePos..., currentHeight - 0.4) .+ pos for pos in gateRelation]
            notify(selectorPositions)
            return Consume(true)
        end
        mousePos = mouseposition(ax.scene)
        # println(mousePos)
        distance, index = findmin([sqrt(sum((mousePos .- point) .^ 2)) for point in lattice.gridPositions])
        if distance < 0.2
            tree, mapping = construct_tree(graph, index, MonitoredQuantumCircuits.nQubits(selectorOperation()))
            possibleMappings = collect(Graphs.Experimental.all_subgraphisomorph(tree, MonitoredQuantumCircuits.connectionGraph(selectorOperation()), vertex_relation=(g1, g2) -> (
                g2 != 1 ? true : mapping[g1] == index
            )))
            if !isempty(possibleMappings)
                selectorPositions[] = [Point3f(gridPositions[mapping[n[1]]]..., currentHeight - 0.1) for n in possibleMappings[mod1(scrollSelect, length(possibleMappings))]]
                notify(selectorPositions)
                selected[] = [mapping[n[1]] for n in possibleMappings[mod1(scrollSelect, length(possibleMappings))]]
                notify(selected)
                return Consume(true)
            end
        end
        selectorPositions[] = [Point3f(mousePos..., currentHeight - 0.2) .+ pos for pos in gateRelation]
        notify(selectorPositions)
        empty!(selected[])
        notify(selected)
        return Consume(true)
    end
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
