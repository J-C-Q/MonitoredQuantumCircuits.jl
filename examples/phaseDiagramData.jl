using MPI
MPI.Init()
comm = MPI.COMM_WORLD
using JLD2

for id in 0:(MPI.Comm_size(comm)-1)
    if id == MPI.Comm_rank(comm)
        using MonitoredQuantumCircuits
    end
    MPI.Barrier(comm)
end



function generateProbs(size; grain=0.1)
    points = NTuple{3,Float64}[]

    for i in 0:grain:1
        for j in i:grain:1
            px = i
            py = j - i
            pz = 1 - j
            push!(points, (px, py, pz))
        end
    end
    d = div(length(points), size)
    return collect(Iterators.partition(points, d))
end



function generateData(probs; nx=6, ny=4, depth=1500 * (nx * ny)^2, shots=10000)
    lattice = HeavyHexagonLattice(nx, ny)
    backend = Stim.CompileSimulator()
    points = probs

    tmis = Vector{Float64}(undef, length(points))
    for (i, (px, py, pz)) in enumerate(points)
        circuit = KitaevCircuit(lattice, px, py, pz, depth)

        result = execute(circuit, backend; shots, verbose=false)

        bits = result[end-MonitoredQuantumCircuits.nQubits(lattice)+1:end]

        tripartiteInformation = Analysis.TMI(bits, [1, 2, 7, 8, 13, 14, 19, 20], [3, 4, 9, 10, 15, 16, 21, 22], [5, 6, 11, 12, 17, 18, 23, 24])

        tmis[i] = tripartiteInformation
    end
    return tmis
end

points = generateProbs(MPI.Comm_size(comm); grain=0.01)

tmis = generateData(points[MPI.Comm_rank(comm)+1]; shots=100000)
MPI.Barrier(comm)

if MPI.Comm_rank(comm) == 0
    # Only the root process needs the big vector to gather into
    big_tmis = Vector{Float64}(undef, sum(length(point) for point in points))
    tmisBuffer = VBuffer(big_tmis, [length(point) for point in points])
else
    big_tmis = nothing  # Other processes do not need this
    tmisBuffer = VBuffer(nothing)
end


# Gather all the data into the big vector
MPI.Gatherv!(tmis, tmisBuffer, 0, comm)
MPI.Barrier(comm)
if MPI.Comm_rank(comm) == 0
    big_points = collect(Iterators.flatten(points))
    JLD2.@save "tmis.jld2" big_tmis big_points
end
