# using ThreadPinning
using MPI
using ProgressMeter
using JLD2
MPI.Init()

comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
world_size = MPI.Comm_size(comm)
nworkers = world_size - 1
root = 0

# pinthreads(:numa)
MPI.Barrier(comm)

for id in 1:nworkers
    if id == rank
        using MonitoredQuantumCircuits

        println("Rank $(rank) ready")
    end
    MPI.Barrier(comm)
end
MPI.Barrier(comm)

function generateProbs(; N=8)
    points = NTuple{3,Float64}[]
    startPoint = (0.8, 0.1, 0.1)
    endPoint = (1 / 3, 1 / 3, 1 / 3)
    points = [startPoint .+ i .* (endPoint .- startPoint) for i in range(0, 1, N)]
    return points
end

function computeOnePoint(point, depth; nx=24, ny=24, shots=2, trajectories=2)
    entanglements = zeros(nx * ny)
    lattice = HexagonToricCodeLattice(nx, ny)
    backend = QuantumClifford.TableauSimulator()
    px, py, pz = point
    Threads.@threads for _ in 1:trajectories
        # for _ in 1:trajectories
        circuit = KitaevCircuit(lattice, px, py, pz, depth)
        for _ in 1:shots
            result = execute(circuit, backend; verbose=false)
            for i in round.(Int, collect(range(1, nx * ny - 1, 50)))
                entanglements[i] += QuantumClifford.QC.entanglement_entropy(result.stab, 1:i, Val(:rref))
                # bits = result[end-MonitoredQuantumCircuits.nQubits(lattice)+1:end]
            end
            result = nothing  # Free the memory
        end
        # println("worker $rank: traject: $i")
        circuit = nothing  # Free the memory
        # tripartiteInformation += Analysis.TMI(bits, 1:4, 5:8, 9:12)
        # bits = nothing  # Free the memory
    end
    return Tuple(entanglements ./ (trajectories * shots * MonitoredQuantumCircuits.nQubits(lattice)))
end

# if MPI.Comm_rank(comm) == 0
#     points, results = master(nprocs, comm)
#     println("All tasks completed. Results: ", results)
#     JLD2.@save "tmis.jld2" results points
# else
#     worker(MPI.Comm_rank(comm), comm)
# end


function job_queue(data, f; resultType=Float64, fileName="simulation")
    T = eltype(data)
    N = length(data)
    send_data = Array{Tuple{T,Bool}}(undef, 1)
    send_result = Array{resultType}(undef, 1)
    recv_data = Array{Tuple{T,Bool}}(undef, 1)
    recv_result = Array{resultType}(undef, 1)

    if rank == root # I am root

        idx_recv = 0
        idx_sent = 1

        results = Array{resultType}(undef, N)
        # Array of workers requests
        sreqs_workers = Array{MPI.Request}(undef, nworkers)
        # -1 = start, 0 = channel not available, 1 = channel available
        status_workers = ones(nworkers) .* -1
        # task index
        taskIndex_workers = zeros(Int64, nworkers)

        # Send message to workers
        for dst in 1:nworkers
            if idx_sent > N
                break
            end
            send_data[1] = (data[idx_sent], false)
            sreq = MPI.Isend(send_data, comm; dest=dst, tag=dst + 32)
            sreqs_workers[dst] = sreq
            status_workers[dst] = 0
            taskIndex_workers[dst] = idx_sent
            # print("Point $(idx_sent)/$N queued on Worker $dst\n")
            idx_sent += 1
        end
        p = Progress(N; dt=1.0)
        # Send and receive messages until all elements are added
        while idx_recv != N
            # Check to see if there is an available message to receive
            for dst in 1:nworkers
                if status_workers[dst] == 0
                    flag = MPI.Test(sreqs_workers[dst])
                    if flag
                        status_workers[dst] = 1
                    end
                end
            end
            for dst in 1:nworkers
                if status_workers[dst] == 1
                    ismessage = MPI.Iprobe(comm; source=dst, tag=dst + 32)
                    if ismessage
                        # Receives message
                        MPI.Recv!(recv_result, comm; source=dst, tag=dst + 32)
                        idx_recv += 1
                        results[taskIndex_workers[dst]] = recv_result[1]
                        update!(p, idx_recv)
                        # print("$idx_recv/$N done!\n")
                        if idx_sent <= N
                            send_data[1] = (data[idx_sent], false)
                            # Sends new message
                            sreq = MPI.Isend(send_data, comm; dest=dst, tag=dst + 32)
                            sreqs_workers[dst] = sreq
                            status_workers[dst] = 1
                            taskIndex_workers[dst] = idx_sent
                            # print("Point $(idx_sent)/$N queued on Worker $dst\n")
                            idx_sent += 1
                        end
                    end
                end
            end
        end

        for dst in 1:nworkers
            # Termination message to worker
            send_data[1] = (send_data[1][1], true)
            sreq = MPI.Isend(send_data, comm; dest=dst, tag=dst + 32)
            sreqs_workers[dst] = sreq
            status_workers[dst] = 0
            taskIndex_workers[dst] = 0
            # print("Root: Finish Worker $dst\n")
        end

        MPI.Waitall(sreqs_workers)
        print("Root: result = $results\n")
        JLD2.@save "$fileName.jld2" results data
    else # If rank == worker
        # -1 = start, 0 = channel not available, 1 = channel available
        status_worker = -1
        while true
            sreqs_workers = Array{MPI.Request}(undef, 1)
            ismessage = MPI.Iprobe(comm; source=root, tag=rank + 32)

            if ismessage
                # Receives message
                MPI.Recv!(recv_data, comm; source=root, tag=rank + 32)
                # Termination message from root
                if recv_data[1][2] == true
                    # print("Worker $rank: Finish\n")
                    break
                end
                # Apply function
                send_result[1] = f(recv_data[1][1]...)
                sreq = MPI.Isend(send_result, comm; dest=root, tag=rank + 32)
                sreqs_workers[1] = sreq
                status_worker = 0
            end
            # Check to see if there is an available message to receive
            if status_worker == 0
                flag = false
                try
                    flag = MPI.Test(sreqs_workers[1])
                catch

                end
                if flag
                    status_worker = 1
                end
            end
        end
    end
    MPI.Barrier(comm)
    MPI.Finalize()
end

points = generateProbs()
job_queue([(p, 2000 * 2 * 24 * 24) for p in points], computeOnePoint; resultType=NTuple{24 * 24,Float64}, fileName="simulation_24x24_entanglement")
