module GUI
using Bonito
using Graphs
using WGLMakie

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
    linesegments!(ax, connections, color=:gray, linewidth=2)
    colors = Observable([:gray for _ in 1:length(lattice)])
    p = scatter!(ax, Point2f.(lattice.gridPositions), markerspace=:data, markersize=0.8, color=colors)

    selected = Observable(Int64[])



    deregister_interaction!(ax, :rectanglezoom)
    deregister_interaction!(ax, :dragpan)

    on(events(fig).mousebutton, priority=2) do event
        if event.button == Mouse.left && event.action == Mouse.press

            # Delete marker
            plt, i = pick(fig)
            if plt == p
                apply!(circuit, ZZ(), selected[]...)
                println(circuit)
                notify(colors)
                return Consume(true)
            end

        end
        return Consume(false)
    end

    on(events(fig).mouseposition, priority=2) do event
        # println("Position = ", mouseposition(ax))
        mousePos = mouseposition(ax)
        distances = [sqrt(sum((mousePos .- point) .^ 2)) for point in lattice.gridPositions]
        perm = sortperm(distances)
        subgraph = induced_subgraph(lattice.graph, [perm[1:3]...])
        if Graphs.Experimental.has_induced_subgraphisomorph(subgraph[1], connectionGraph(ZZ()))
            colors[] = fill(:gray, length(lattice))
            for point in perm[1:3]
                colors[][point] = :red
            end
            selected[] = perm[1:3]
            notify(selected)
            notify(colors)
            return Consume(true)
        else
            colors[] = fill(:gray, length(lattice))
            empty!(selected[])
            notify(selected)
            notify(colors)
            return Consume(true)

        end
        return Consume(false)
    end

    # println(interactions(ax))
    fig
end

end
