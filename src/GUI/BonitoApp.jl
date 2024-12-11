module GUI
using Bonito
using Graphs
using WGLMakie
using Combinatorics
using InteractiveUtils
using FileIO
using Colors
using LinearAlgebra
# import ..Lattice
# import ..Circuit
# import ..EmptyCircuit
# import ..apply!
# import ..ZZ
# import ..connectionGraph
import ...MonitoredQuantumCircuits

"""
    CircuitComposer!(circuit::FiniteDepthCircuit)

Launch a GUI to visually compose and edit a quantum circuit.
"""
function CircuitComposer!(circuit::MonitoredQuantumCircuits.FiniteDepthCircuit)
    # circuit = MonitoredQuantumCircuits.EmptyCircuit(lattice)
    app = App() do
        buttons = [Button("$operation", style=Styles(
            CSS("font-size" => "16px",
                "aspect-ratio" => "1 / 1",
                "background-color" => "white",
                "padding-left" => "0px",
                "padding-right" => "0px",
                "padding-top" => "0px",
                "padding-bottom" => "0px",
                "width" => "75px",
                "min-width" => "0",
                "margin" => "0px",
                "border-radius" => "8px",),
            CSS(":hover", "background-color" => "silver"),
            CSS(":focus", "box-shadow" => "rgba(0, 0, 0, 0.5) 0px 0px 5px"),
        )) for (i, operation) in enumerate(cat([t for t in subtypes(MonitoredQuantumCircuits.Operation) if t != MonitoredQuantumCircuits.MeasurementOperation], subtypes(MonitoredQuantumCircuits.MeasurementOperation), dims=1))]

        plot_div = DOM.div(makie_plot(circuit, buttons), style="width: 100%; height: 100%;")

        return DOM.div(
            plot_div,
            Bonito.Grid(buttons...,
                columns="repeat($(floor(Int64,sqrt(length(buttons)))), 1fr)",
                rows="repeat($(ceil(Int64,sqrt(length(buttons)))), 1fr)",
                style=Styles(
                    CSS("margin" => "0px",
                        "padding" => "0px",
                        "height" => "auto",
                        "width" => "auto",
                        "position" => "absolute",
                        "top" => "0",
                        "gap" => "8px",
                        "right" => "0",
                        "transform" => "translate(0,0)",
                        "background-color" => "gray",
                        "padding" => "8px",
                        "border-radius" => "0 0 0 8px",))),
            style=Styles(
                CSS("margin" => "0px",
                    "padding" => "0px",
                    "height" => "calc(100vh - 16px)",
                    "width" => "calc(100vw - 16px)",)
            )
        )
    end
    # example_app = App(DOM.div("hello world"), title="hello world")
    # server = Bonito.Server(app, "134.95.67.139", 2000)
    return app
end
function makie_plot(circuit::MonitoredQuantumCircuits.FiniteDepthCircuit, buttons)
    lattice = circuit.lattice
    gridPositions = lattice.gridPositions
    graph = lattice.graph
    cyclinderMesh = load("src/GUI/meshes/cylinder.stl")
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
        eyeposition=Vec3((limits[2] + limits[1]) / 2, (limits[4] + limits[3]) / 2, -max(abs(limits[2] - limits[1]), abs(limits[4] - limits[3])) * 0.76),
        lookat=Vec3((limits[2] + limits[1]) / 2, (limits[4] + limits[3]) / 2, 0),
        upvector=Vec3(0, -1, 0),
        center=false,
        cad=false,
        zoom_shift_lookat=false, fixed_axis=true,
        clipping_mode=:static,
        near=1.0f-10,
        far=1.0f10,)

    # limit zoom
    on(ax.scene.camera_controls.eyeposition) do b
        if norm(cam.eyeposition[] .- cam.lookat[]) < 8.0
            cam.eyeposition[] = cam.lookat[] .+ 8.0 .* normalize(cam.eyeposition[] .- cam.lookat[])
            update_cam!(ax.scene, cam.eyeposition[], cam.lookat[], cam.upvector[])
        elseif norm(cam.eyeposition[] .- cam.lookat[]) > 10.0
            cam.eyeposition[] = cam.lookat[] .+ 10.0 .* normalize(cam.eyeposition[] .- cam.lookat[])
            update_cam!(ax.scene, cam.eyeposition[], cam.lookat[], cam.upvector[])
        end
        if cam.eyeposition[][3] > 0.0
            cam.eyeposition[] = Vec3(cam.eyeposition[][1], cam.eyeposition[][2], 0.0)
            # cam.upvector[] = Vec3(cam.upvector[][1], cam.upvector[][2], -1.0)
            update_cam!(ax.scene, cam)
        end
    end

    # limit azimuth
    on(ax.scene.camera_controls.eyeposition) do b

        # if cam.upvector[][3] > 0.0
        #     cam.upvector[] = cam.upvector[] .- Vec3(0, 0, cam.upvector[][3])
        #     update_cam!(ax.scene, cam.eyeposition[], cam.lookat[], cam.upvector[])
        # end
        println(ax.scene.camera_controls.upvector[])
    end





    # update_cam!(ax.scene, bbox)
    # zoom!(ax.scene, 0.76)
    # update_cam!(ax.scene, Vec3(limits[2], limits[4], -max(abs(limits[2] - limits[1]), abs(limits[4] - limits[3])) * 0.3), Vec3(limits[2], (limits[4] + limits[3]) / 2, 0), Vec3(0, -1, 0))

    begin #! Graph plot
        connections = Point3f[]
        connectionRotations = Vec3f[]
        connectionScale = Vec3f[]
        for e in collect(edges(graph))
            src = Graphs.src(e)
            dst = Graphs.dst(e)
            push!(connections, Point3f(((gridPositions[src] .+ gridPositions[dst]) ./ 2)..., 0))
            push!(connectionRotations, Point3f((gridPositions[dst] .- gridPositions[src])..., 0))
            push!(connectionScale, Vec3f(0.1, 0.1, sqrt(sum((gridPositions[dst] .- gridPositions[src]) .^ 2))))
            # push!(connections, Point3f(gridPositions[src]..., 0))
            # push!(connections, Point3f(gridPositions[dst]..., 0))
        end
        # linesegments!(ax,
        #     connections,
        #     color=:gray,
        #     linewidth=2)
        meshscatter!(ax,
            connections,
            color=:gray,
            marker=cyclinderMesh,
            rotation=connectionRotations,
            markersize=connectionScale)
        markerSizes = fill(0.2, length(gridPositions))
        for (i, pos) in enumerate(gridPositions)
            if lattice.isAncilla[i]
                markerSizes[i] = 0.1
            end
        end
        meshscatter!(ax,
            Point3f.([(pos..., 0) for pos in gridPositions]),
            markersize=markerSizes,
            color=:gray)
    end

    begin #! select plot
        selectorOperation = allOperations[1]
        selectorColor = Observable(parse(Colorant, MonitoredQuantumCircuits.color(selectorOperation())))
        selectorConnectionColor = Observable(parse(Colorant, MonitoredQuantumCircuits.color(selectorOperation())))
        selectorLabels = ["$i" for i in 1:MonitoredQuantumCircuits.nQubits(selectorOperation())]
        scrollSelect = 1
        selectorSize = Observable(fill(0.2, MonitoredQuantumCircuits.nQubits(selectorOperation())))
        for i in 1:MonitoredQuantumCircuits.nQubits(selectorOperation())
            if MonitoredQuantumCircuits.isAncilla(selectorOperation(), i)
                selectorSize[][i] = 0.1
            end
        end

        gateRelation = Point3f[Point3f(i, j, -1) for (i, j) in MonitoredQuantumCircuits.plotPositions(selectorOperation())]
        selectorPositions = Observable(gateRelation)

        selectorConnections = Observable([(gateRelation[i+1] .+ gateRelation[i]) ./ 2 for i in 1:length(gateRelation)-1])
        selectorRotations = Observable([gateRelation[i+1] .- gateRelation[i] for i in 1:length(gateRelation)-1])
        selectorScale = Observable([Vec3f(0.2, 0.2, sqrt(sum((gateRelation[i+1] .- gateRelation[i]) .^ 2))) for i in 1:length(gateRelation)-1])

        showSelector = Observable(false)

        # lines!(ax,
        #     selectorPositions,
        #     linewidth=4,
        #     color=:black,
        #     visible=showSelector)
        meshscatter!(ax,
            selectorConnections,
            marker=cyclinderMesh,
            color=selectorConnectionColor,
            rotation=selectorRotations,
            markersize=selectorScale,
            visible=showSelector
        )
        meshscatter!(ax,
            selectorPositions,
            color=:gray,
            markersize=selectorSize,
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
        gateConnectionColors = Observable(Colorant[])
        gateConnectionRotations = Observable(Vec3f[])
        gateConnectionScale = Observable(Vec3f[])
        gateColors = Observable(Colorant[])
        currentHeight = -0.4
        currentHeights = zeros(Float32, length(lattice))
        currentStep = zeros(Int64, length(lattice))
        for exec in sort(unique(circuit.executionOrder))
            ops = MonitoredQuantumCircuits._getOperations(circuit, exec)
            operations = [circuit.operationPositions[operation] for operation in ops]
            height = -0.4 * exec
            currentHeight = height
            for (i, pos) in enumerate(operations)
                for p in pos
                    push!(gateColors[], parse(Colorant, MonitoredQuantumCircuits.color(circuit.operations[circuit.operationPointers[ops[i]]])))
                    push!(gatePositions[], Point3f(gridPositions[p]..., height))


                    currentStep[p] = exec
                    currentHeights[p] = height


                end
                for (j, p) in enumerate(pos[1:end-1])
                    push!(gateConnections[], Point3f(((gridPositions[p] .+ gridPositions[pos[j+1]]) ./ 2)..., height))
                    push!(gateConnectionRotations[], Vec3f(((gridPositions[pos[j+1]] .- gridPositions[p]))..., 0))
                    push!(gateConnectionScale[], Vec3f(0.2, 0.2, sqrt(sum((gridPositions[pos[j+1]] .- gridPositions[p]) .^ 2))))
                    push!(gateConnectionColors[], parse(Colorant, MonitoredQuantumCircuits.color(circuit.operations[circuit.operationPointers[ops[i]]])))
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
            marker=cyclinderMesh,
            markersize=gateConnectionScale,
            rotation=gateConnectionRotations)
    end


    selected = Observable(Int64[])
    movable = true


    for (i, button) in enumerate(buttons)
        on(button.value) do click::Bool
            movable = false
            update_cam!(ax.scene, Vec3((limits[2] + limits[1]) / 2, (limits[4] + limits[3]) / 2, -max(abs(limits[2] - limits[1]), abs(limits[4] - limits[3])) * 0.76), Vec3((limits[2] + limits[1]) / 2, (limits[4] + limits[3]) / 2, 0), Vec3(0, -1, 0))
            selectorOperation = allOperations[i]
            selectorColor[] = parse(Colorant, MonitoredQuantumCircuits.color(selectorOperation()))
            selectorConnectionColor[] = parse(Colorant, MonitoredQuantumCircuits.color(selectorOperation()))
            showSelector[] = true
            notify(selectorColor)
            notify(selectorConnectionColor)
            notify(showSelector)
        end
    end

    on(events(fig).mousebutton, priority=2) do event
        if event.button == Mouse.left && event.action == Mouse.press
            if movable
                return Consume(false)
            end
            if !isempty(selected[]) && showSelector[]
                step = maximum([currentStep[i] for i in selected[]]) + 1
                MonitoredQuantumCircuits.apply!(circuit, step, selectorOperation(), selected[]...)
                println(circuit)
                height = minimum([currentHeights[i] for i in selected[]])
                if height == currentHeight
                    currentHeight -= 0.4
                end
                height -= 0.4
                for pos in selected[]
                    push!(gateColors[], parse(Colorant, MonitoredQuantumCircuits.color(selectorOperation())))
                    push!(gatePositions[], Point3f(gridPositions[pos]..., height))
                    currentHeights[pos] = height
                    currentStep[pos] = step
                end
                for (i, p) in enumerate(selected[][1:end-1])
                    push!(gateConnections[], Point3f(((gridPositions[p] .+ gridPositions[selected[][i+1]]) ./ 2)..., height))
                    push!(gateConnectionRotations[], Vec3f((gridPositions[selected[][i+1]] .- gridPositions[p])..., 0))
                    push!(gateConnectionScale[], Vec3f(0.2, 0.2, sqrt(sum((gridPositions[selected[][i+1]] .- gridPositions[p]) .^ 2))))
                    push!(gateConnectionColors[], parse(Colorant, MonitoredQuantumCircuits.color(selectorOperation())))
                end
                notify(gateConnections)
                notify(gateConnectionRotations)
                notify(gateConnectionScale)
                notify(gateConnectionColors)
                # println(gateConnections[])
                notify(gatePositions)
                notify(gateColors)

                # showSelector[] = false
                # notify(showSelector)
                empty!(selected[])
                return Consume(true)
            else
                showSelector[] = false
                movable = true
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
            selectorConnections[] = [(selectorPositions[][i+1] .+ selectorPositions[][i]) ./ 2 for i in 1:length(selectorPositions[])-1]
            selectorRotations[] = [selectorPositions[][i+1] .- selectorPositions[][i] for i in 1:length(selectorPositions[])-1]
            selectorScale[] = [Vec3f(0.2, 0.2, sqrt(sum((selectorPositions[][i+1] .- selectorPositions[][i]) .^ 2))) for i in 1:length(selectorPositions[])-1]
            notify(selectorScale)
            notify(selectorRotations)
            notify(selectorConnections)
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
                selectorConnections[] = [(selectorPositions[][i+1] .+ selectorPositions[][i]) ./ 2 for i in 1:length(selectorPositions[])-1]
                selectorRotations[] = [selectorPositions[][i+1] .- selectorPositions[][i] for i in 1:length(selectorPositions[])-1]
                selectorScale[] = [Vec3f(0.2, 0.2, sqrt(sum((selectorPositions[][i+1] .- selectorPositions[][i]) .^ 2))) for i in 1:length(selectorPositions[])-1]
                notify(selectorScale)
                notify(selectorRotations)
                notify(selectorConnections)
                notify(selectorPositions)
                selected[] = [mapping[n[1]] for n in possibleMappings[mod1(scrollSelect, length(possibleMappings))]]
                notify(selected)
                return Consume(true)
            end
        end
        selectorPositions[] = [Point3f(mousePos..., currentHeight - 0.2) .+ pos for pos in gateRelation]
        selectorConnections[] = [(selectorPositions[][i+1] .+ selectorPositions[][i]) ./ 2 for i in 1:length(selectorPositions[])-1]
        selectorRotations[] = [selectorPositions[][i+1] .- selectorPositions[][i] for i in 1:length(selectorPositions[])-1]
        selectorScale[] = [Vec3f(0.2, 0.2, sqrt(sum((selectorPositions[][i+1] .- selectorPositions[][i]) .^ 2))) for i in 1:length(selectorPositions[])-1]
        notify(selectorScale)
        notify(selectorRotations)
        notify(selectorConnections)
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
