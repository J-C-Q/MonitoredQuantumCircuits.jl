module MonitoredQuantumCircuitsMPIExt
using MPI
using MonitoredQuantumCircuits
println("MPI loaded")
# Ensure MPI is initialized
function __init__()
    if !MPI.Initialized()
        MPI.Init()
        atexit(MPI.Finalize)
    end
end

function MonitoredQuantumCircuits.get_mpi_ref()
    rank = MPI.Comm_rank(MPI.COMM_WORLD)
    size = MPI.Comm_size(MPI.COMM_WORLD)
    # println("Running on $(rank+1) of $size")
    # Threads.@threads for i in samples÷size
    #     sim = deepcopy(backend)
    #     # Execute the circuit on the local backend
    #     result = execute(circuit, sim)
    #     # Save the result to a file or process it as needed
    #     JLD2.save("result_$(rank+1)_$(i).jld2", "result", result)
    # end

    # return result
    return MPI, rank, size
end

end
