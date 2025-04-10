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
    return MPI, rank, size
end
end
# mpirun --bind-to none -np 2 -host l19,l90 nice -n 19 path/to/julia -t 20 --project file.jl
