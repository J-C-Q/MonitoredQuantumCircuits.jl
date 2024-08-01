struct HeavySquareLattice <: Lattice
    graph::Graph
    sizeX::Int64
    sizeY::Int64
    isAncilla::Vector{Bool} # whether the qubit is an ancilla
    gridPositions::Vector{Tuple{Int64,Int64}} # the grid positions of the qubits
    physicalMap::Vector{Int64} # the mapping to the physical qubits indices on a device
    function HeavySquareLattice(sizeX::Integer, sizeY::Integer)
        sizeX > 0 || throw(ArgumentError("size must be positive"))
        sizeY > 0 || throw(ArgumentError("size must be positive"))
        graph = grid([sizeX, sizeY]; periodic=false)
        nNodes = nv(graph)
        gridPositions = [(2i - 1, 2j - 1) for j in 1:sizeY for i in 1:sizeX]
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


        physicalMap = fill(-1, nv(graph))
        return new(graph, sizeX, sizeY, isAncilla, physicalMap)
    end
end

function visualize(io::IO, lattice::HeavySquareLattice)
    for _ in 1:lattice.sizeY-1
        for _ in 1:2lattice.sizeX-2
            print(io, "○ ─ ")
        end
        println(io, "○")
        for i in 1:2lattice.sizeX-2
            if i % 2 == 1
                print(io, "|   ")
            else
                print(io, "    ")
            end
        end
        println(io, "|")
        for i in 1:2lattice.sizeX-2
            if i % 2 == 1
                print(io, "○   ")
            else
                print(io, "    ")
            end
        end
        println(io, "○")
        for i in 1:2lattice.sizeX-2
            if i % 2 == 1
                print(io, "|   ")
            else
                print(io, "    ")
            end
        end
        println(io, "|")

    end
    for _ in 1:2lattice.sizeX-2
        print(io, "○ ─ ")
    end
    println(io, "○")


    return nothing
end
