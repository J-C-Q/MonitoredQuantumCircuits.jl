
function mysimplecycles_limited_length(
    graph::AbstractGraph{T}, n::Int, ceiling=10^6
) where {T}
    cycles = Vector{Vector{T}}()
    n < 1 && return cycles
    cycle = Vector{T}(undef, n)
    @inbounds for v in vertices(graph)
        cycle[1] = v
        mysimplecycles_limited_length!(graph, n, ceiling, cycles, cycle, 1)
        length(cycles) >= ceiling && break
    end
    return cycles
end

function mysimplecycles_limited_length!(graph, n, ceiling, cycles, cycle, i)
    length(cycles) >= ceiling && return nothing
    for v in outneighbors(graph, cycle[i])
        if v == cycle[1] && i == n && cycle[2] < cycle[n]
            push!(cycles, cycle[1:i])
        elseif (i < n && v > cycle[1] && !Graphs.repeated_vertex(v, cycle, 2, i))
            cycle[i+1] = v
            mysimplecycles_limited_length!(graph, n, ceiling, cycles, cycle, i + 1)
        end
    end
end
