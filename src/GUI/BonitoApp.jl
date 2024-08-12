module GUI
using Bonito
using WGLMakie

import ..Lattice

function CircuitComposer(lattice::Lattice)

    App() do
        return makie_plot(lattice)
    end
    # example_app = App(DOM.div("hello world"), title="hello world")
end
function makie_plot(lattice)
    fig = Figure()
    ax = Axis(fig[1, 1])
    scatter!(ax, Point2f.(lattice.gridPositions))
    fig
end
end
