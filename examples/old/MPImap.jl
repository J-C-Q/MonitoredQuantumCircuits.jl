using MPI
using JLD2
using ProgressMeter

function mpi_map(f::Function, args::AbstractVector{Tuple}, outputType=Float64)
    # Initialize MPI
    MPI.Init()
    comm = MPI.COMM_WORLD
    rank = MPI.Comm_rank(comm)
    size = MPI.Comm_size(comm)

    if rank == 0
        # Master process
        num_tasks = length(args)
        tasks_assigned = 0
        tasks_completed = 0
        results = Vector{outputType}(undef, num_tasks)
        p = Progress(num_tasks)

        # Assign initial tasks to workers
        for worker = 1:min(size - 1, num_tasks)
            task_id = tasks_assigned + 1
            task = args[task_id]
            MPI.send((task_id, task), worker, 0, comm)
            tasks_assigned += 1
        end

        while tasks_completed < num_tasks
            # Receive results from any worker
            result_data, status = MPI.recv(MPI.ANY_SOURCE, 2, comm)
            worker = status.source
            task_id, res = result_data
            results[task_id] = res
            tasks_completed += 1
            update!(p, tasks_completed)

            # Checkpoint: save intermediate results
            if tasks_completed % 10 == 0 || tasks_completed == num_tasks
                @save "results.jld2" results
            end

            if tasks_assigned < num_tasks
                # Send next task to the worker
                task_id = tasks_assigned + 1
                task = args[task_id]
                MPI.send((task_id, task), worker, 0, comm)
                tasks_assigned += 1
            else
                # No more tasks; send termination signal
                MPI.send(nothing, worker, 1, comm)
            end
        end

        finish!(p)

    else
        # Worker process
        while true
            # Receive task from master
            task_data, status = MPI.recv(0, MPI.ANY_TAG, comm)
            if status.tag == 0
                task_id, task = task_data
                # Execute the function (can include internal parallelism)
                res = f(task...)
                # Send result back to master
                MPI.send((task_id, res), 0, 2, comm)
            elseif status.tag == 1
                # Termination signal received
                break
            end
        end
    end

    MPI.Barrier(comm)
    MPI.Finalize()
end
