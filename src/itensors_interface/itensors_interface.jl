module ITensorsInterface
using ITensorNetworks
using NamedGraphs.GraphsExtensions: subgraph
using NamedGraphs.NamedGraphGenerators: named_grid

export simple_PEPS

"""
    simple_PEPS()

Create a simple PEPS tensor network with a 2x2 grid of tensors and bond dimension 2.

# Returns
- `ITensorNetwork`: the simple PEPS tensor network
"""
function simple_PEPS()
    return ITensorNetwork(named_grid((2, 2)); link_space=2)
end
end
