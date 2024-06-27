struct HeavyHexagonLattice <: Lattice
    graph::Graph
    sizeX::Int64
    sizeY::Int64
    physicalMap::Vector{Int64} # the mapping to the physical qubits indices on a device
    function HeavyHexagonLattice(sizeX::Integer, sizeY::Integer)
        sizeX > 0 || throw(ArgumentError("size must be positive"))
        sizeY > 0 || throw(ArgumentError("size must be positive"))
        graph = grid([sizeX, sizeY]; periodic=false)

        for j in 1:sizeY-1
            for i in (j%2+1+(j-1)*(sizeX)):2:j*(sizeX)
                rem_edge!(graph, i, i + sizeX)
            end
        end
        # rem_edge!(graph, sizeX, sizeX + 1)
        # rem_edge!(graph, (sizeY - 1) * (sizeX + 1), (sizeY - 1) * (sizeX + 1) + 1)
        # if isodd(sizeY) && isodd(sizeX)
        #     rem_vertex!(graph, sizeX + 1)
        #     rem_vertex!(graph, (sizeY - 1) * (sizeX + 1) + 1)
        # elseif isodd(sizeY) && iseven(sizeX)
        #     rem_vertex!(graph, nv(graph))
        #     rem_vertex!(graph, (sizeY - 1) * (sizeX + 1) + 1)
        # elseif iseven(sizeY) && isodd(sizeX)
        #     rem_vertex!(graph, nv(graph))
        #     rem_vertex!(graph, sizeX + 1)
        # end

        nNodes = nv(graph)
        for e in collect(edges(graph))
            src = Graphs.src(e)
            dst = Graphs.dst(e)
            rem_edge!(graph, e)
            add_vertex!(graph)
            nNodes += 1

            add_edge!(graph, src, nNodes)
            add_edge!(graph, nNodes, dst)
        end
        physicalMap = fill(-1, nv(graph))
        return new(graph, sizeX, sizeY, physicalMap)
    end
end
function visualize(io::IO, lattice::HeavyHexagonLattice)

    for _ in 1:2lattice.sizeX-2
        print(io, "o - ")
    end
    println(io, "o")
    for j in 2:2lattice.sizeY-1
        if j % 2 == 0
            if j % 4 == 0
                print(io, "        ")
                for i in 1:2:lattice.sizeX-3
                    print(io, "|               ")
                end
                println(io, "|")
                print(io, "        ")
                for i in 1:2:lattice.sizeX-3
                    print(io, "o               ")
                end
                println(io, "o")
                print(io, "        ")
                for i in 1:2:lattice.sizeX-3
                    print(io, "|               ")
                end
                println(io, "|")

            else
                for i in 1:2:lattice.sizeX-2
                    print(io, "|               ")
                end
                println(io, "|")
                for i in 1:2:lattice.sizeX-2
                    print(io, "o               ")
                end
                println(io, "o")
                for i in 1:2:lattice.sizeX-2
                    print(io, "|               ")
                end
                println(io, "|")
            end

        else
            for _ in 1:2lattice.sizeX-2
                print(io, "o - ")
            end
            println(io, "o")
        end
    end
    # print(io, "        ")
    # for _ in 1:2lattice.sizeX-2
    #     print(io, "o - ")
    # end
    # println(io, "o")
    return nothing
end
