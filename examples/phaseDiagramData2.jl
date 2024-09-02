using MPI
MPI.Init()
comm = MPI.COMM_WORLD
using JLD2

# Load MonitoredQuantumCircuits on all processes in serial
for id in 1:(MPI.Comm_size(comm)-1)
    if id == MPI.Comm_rank(comm)
        using MonitoredQuantumCircuits
        println("Rank $(MPI.Comm_rank(comm)) ready")
    end
    MPI.Barrier(comm)
end

function generateProbs(; grain=0.1)
    points = NTuple{3,Float64}[]
    for i in 0:grain:1
        for j in i:grain:1
            px = i
            py = j - i
            pz = 1 - j
            push!(points, (px, py, pz))
        end
    end
    return points
end

function computeOnePoint(point; nx=4, ny=4, depth=1500 * (nx * ny), shots=10000, trajectories=3800)
    tripartiteInformation = 0.0
    for _ in 1:trajectories
        circuit = KitaevCircuit(lattice, px, py, pz, depth)

        result = execute(circuit, backend; shots, verbose=false)
        circuit = nothing  # Free the memory

        bits = result[end-MonitoredQuantumCircuits.nQubits(lattice)+1:end]
        result = nothing  # Free the memory

        tripartiteInformation += Analysis.TMI(bits, 1:4, 5:8, 9:12)
        bits = nothing  # Free the memory
    end
    return tripartiteInformation / trajectories
end

function master(nprocs, comm)
    points = generateProbs()
    tasks = collect(1:length(points))
    ntasks = length(tasks)

    results = Vector{Float64}(undef, ntasks)
    tasks_sent = 0
    tasks_completed = 0

    # Initialize workers
    for worker in 1:(nprocs-1)
        if tasks_sent < ntasks
            MPI.Send(points[tasks_sent+1], worker, 0, comm)
            tasks_sent += 1
        end
    end

    # Receive results and assign new tasks
    while tasks_completed < ntasks
        status = MPI.Status()
        result = MPI.Recv_any!(MPI.ANY_SOURCE, MPI.ANY_TAG, comm, status)
        source = MPI.Status_source(status)
        results[tasks_completed+1] = result
        tasks_completed += 1

        if tasks_sent < ntasks
            MPI.Send(points[tasks_sent+1], source, 0, comm)
            tasks_sent += 1
        else
            # Send termination signal
            MPI.Send(nothing, source, 1, comm)
        end
    end
    return results
end

function worker(rank, comm; nx=4, ny=4, depth=1500 * (nx * ny), shots=10000)
    lattice = HexagonToricCodeLattice(nx, ny)
    backend = Stim.CompileSimulator()
    while true
        status = MPI.Status()
        task = MPI.Recv_any!(0, MPI.ANY_TAG, comm, status)
        if MPI.Status_tag(status) == 1
            break  # Termination signal
        end
        result = computeOnePoint(task; nx, ny, depth, shots)
        MPI.Send(result, 0, 0, comm)
    end
end

if rank == 0
    results = master(nprocs, comm)
    println("All tasks completed. Results: ", results)
else
    worker(rank, comm)
end
if MPI.Comm_rank(comm) == 0
    big_points = collect(Iterators.flatten(points))
    JLD2.@save "tmis.jld2" big_tmis big_points
end
