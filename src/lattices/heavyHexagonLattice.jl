struct HeavyHexagonLattice <: Lattice
    graph::Graph
    sizeX::Int64
    sizeY::Int64
    isAncilla::Vector{Bool} # whether the qubit is an ancilla
    gridPositions::Vector{Tuple{Int64,Int64}} # the grid positions of the qubits
    function HeavyHexagonLattice(sizeX::Integer, sizeY::Integer)
        sizeX > 0 || throw(ArgumentError("size must be positive"))
        sizeY > 0 || throw(ArgumentError("size must be positive"))
        graph = grid([sizeX, sizeY]; periodic=false)

        for j in 1:sizeY-1
            for i in (j%2+1+(j-1)*(sizeX)):2:j*(sizeX)
                rem_edge!(graph, i, i + sizeX)
            end
        end
        gridPositions = [(2i - 1, 2j - 1) for j in 1:sizeY for i in 1:sizeX]
        nNodes = nv(graph)
        for e in collect(edges(graph))
            src = Graphs.src(e)
            dst = Graphs.dst(e)
            rem_edge!(graph, e)
            add_vertex!(graph)
            nNodes += 1
            push!(gridPositions, (round(Int64, (gridPositions[src][1] + gridPositions[dst][1]) / 2), round(Int64, (gridPositions[src][2] + gridPositions[dst][2]) / 2)))
            add_edge!(graph, src, nNodes)
            add_edge!(graph, nNodes, dst)
        end
        isAncilla = Vector{Bool}(undef, nv(graph))
        isAncilla[1:sizeX*sizeY] .= false
        isAncilla[sizeX*sizeY+1:end] .= true
        return new(graph, sizeX, sizeY, isAncilla, gridPositions)
    end
end

function visualize(io::IO, lattice::HeavyHexagonLattice)
    grid = fill(" ", 2 * maximum([pos[2] for pos in lattice.gridPositions]) + 1, 5 * maximum([pos[1] for pos in lattice.gridPositions]) + 3)
    gridColor = fill(:white, 2 * maximum([pos[2] for pos in lattice.gridPositions]) + 1, 5 * maximum([pos[1] for pos in lattice.gridPositions]) + 3)
    for (i, gridPosition) in enumerate(lattice.gridPositions)
        zeroString = String["0", "0", "0"]
        i_as_string = string(i)
        zeroString[end-length(i_as_string)+1:end] .= [string(s) for s in i_as_string]
        grid[2gridPosition[2]-1, 5gridPosition[1]-4] = zeroString[1]
        grid[2gridPosition[2]-1, 5gridPosition[1]-3] = zeroString[2]
        grid[2gridPosition[2]-1, 5gridPosition[1]-2] = zeroString[3]
        if lattice.isAncilla[i]
            gridColor[2gridPosition[2]-1, 5gridPosition[1]-4] = :dark_gray
            gridColor[2gridPosition[2]-1, 5gridPosition[1]-3] = :dark_gray
            gridColor[2gridPosition[2]-1, 5gridPosition[1]-2] = :dark_gray
        end
    end
    for e in collect(edges(lattice.graph))
        src = Graphs.src(e)
        dst = Graphs.dst(e)
        gridPositionSrc = (2lattice.gridPositions[src][2] - 1, 5lattice.gridPositions[src][1] - 3)
        gridPositionDst = (2lattice.gridPositions[dst][2] - 1, 5lattice.gridPositions[dst][1] - 3)
        meanPosition = (round(Int64, (gridPositionSrc[1] + gridPositionDst[1]) / 2), floor(Int64, (gridPositionSrc[2] + gridPositionDst[2]) / 2))
        if gridPositionSrc[1] == gridPositionDst[1]
            grid[meanPosition[1], meanPosition[2]] = "─"
            grid[meanPosition[1], meanPosition[2]+1] = "─"
        else
            grid[meanPosition[1], meanPosition[2]] = "|"
        end

    end


    for j in eachindex(grid[:, 1])
        for i in eachindex(grid[j, :])
            print(io, Crayon(foreground=gridColor[j, i]), grid[j, i])
        end
        println(io)
    end
    return nothing
end
