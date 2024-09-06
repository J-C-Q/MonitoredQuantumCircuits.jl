using MPI
using ProgressMeter
using JLD2
MPI.Init()
comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
world_size = MPI.Comm_size(comm)
nworkers = world_size - 1
root = 0

MPI.Barrier(comm)

for id in 1:nworkers
    if id == rank
        using MonitoredQuantumCircuits

        println("Rank $(rank) ready")
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

function computeOnePoint(point; nx=16, ny=16, depth=1000 * 2 * (nx * ny), shots=1, trajectories=1)
    tripartiteInformation = 0.0
    lattice = HexagonToricCodeLattice(nx, ny)
    backend = QuantumClifford.TableauSimulator()
    px, py, pz = point
    d = div(ny, 4)
    for _ in 1:trajectories
        circuit = KitaevCircuit(lattice, px, py, pz, depth)

        result = execute(circuit, backend; shots, verbose=false)
        circuit = nothing  # Free the memory
        tripartiteInformation += QuantumClifford.tmi(result.stab, 1:nx*d, nx*d+1:2*nx*d, 2*nx*d+1:3*nx*d)
        # bits = result[end-MonitoredQuantumCircuits.nQubits(lattice)+1:end]
        result = nothing  # Free the memory

        # tripartiteInformation += Analysis.TMI(bits, 1:4, 5:8, 9:12)
        # bits = nothing  # Free the memory
    end
    return tripartiteInformation / trajectories
end

# if MPI.Comm_rank(comm) == 0
#     points, results = master(nprocs, comm)
#     println("All tasks completed. Results: ", results)
#     JLD2.@save "tmis.jld2" results points
# else
#     worker(MPI.Comm_rank(comm), comm)
# end


function job_queue(data, f)
    T = eltype(data)
    N = length(data)
    send_data = Array{T}(undef, 1)
    send_result = Array{Float64}(undef, 1)
    recv_data = Array{T}(undef, 1)
    recv_result = Array{Float64}(undef, 1)

    if rank == root # I am root

        idx_recv = 0
        idx_sent = 1

        results = Array{Float64}(undef, N)
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
            send_data[1] = data[idx_sent]
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
                            send_data[1] = data[idx_sent]
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
            send_data[1] = (0.0, 0.0, 0.0)
            sreq = MPI.Isend(send_data, comm; dest=dst, tag=dst + 32)
            sreqs_workers[dst] = sreq
            status_workers[dst] = 0
            taskIndex_workers[dst] = 0
            # print("Root: Finish Worker $dst\n")
        end

        MPI.Waitall(sreqs_workers)
        print("Root: result = $results\n")
        JLD2.@save "tmisMixed.jld2" results data
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
                if recv_data[1] == (0.0, 0.0, 0.0)
                    # print("Worker $rank: Finish\n")
                    break
                end
                # Apply function
                send_result = f(recv_data[1])
                sreq = MPI.Isend(send_result, comm; dest=root, tag=rank + 32)
                sreqs_workers[1] = sreq
                status_worker = 0
            end
            # Check to see if there is an available message to receive
            if status_worker == 0
                flag = MPI.Test(sreqs_workers[1])
                if flag
                    status_worker = 1
                end
            end
        end
    end
    MPI.Barrier(comm)
    MPI.Finalize()
end


job_queue(generateProbs(), computeOnePoint)
