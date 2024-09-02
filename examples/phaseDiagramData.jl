using MPI
MPI.Init()
comm = MPI.COMM_WORLD
using JLD2

# Load MonitoredQuantumCircuits on all processes in serial
for id in 0:(MPI.Comm_size(comm)-1)
    if id == MPI.Comm_rank(comm)
        using MonitoredQuantumCircuits
        println("Rank $(MPI.Comm_rank(comm)) ready")
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



function generateData(probs; nx=4, ny=4, depth=1500 * (nx * ny), shots=10000)
    lattice = HexagonToricCodeLattice(nx, ny)
    backend = Stim.CompileSimulator()
    points = probs

    tmis = zeros(Float64, length(points))
    for (i, (px, py, pz)) in enumerate(points)
        for _ in 1:3800
            circuit = KitaevCircuit(lattice, px, py, pz, depth)

            result = execute(circuit, backend; shots, verbose=false)
            circuit = nothing  # Free the memory

            bits = result[end-MonitoredQuantumCircuits.nQubits(lattice)+1:end]
            result = nothing  # Free the memory

            tripartiteInformation = Analysis.TMI(bits, 1:4, 5:8, 9:12)
            bits = nothing  # Free the memory

            tmis[i] += tripartiteInformation
        end
        tmis[i] /= 3800
        # GC.gc()  # Force garbage collection
    end
    return tmis
end

points = generateProbs(MPI.Comm_size(comm); grain=0.1)

tmis = generateData(points[MPI.Comm_rank(comm)+1]; shots=10000, depth=750 * 2 * 16)
MPI.Barrier(comm)

if MPI.Comm_rank(comm) == 0
    # Only the root process needs the big vector to gather into
    big_tmis = zeros(Float64, sum(length(point) for point in points))
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
