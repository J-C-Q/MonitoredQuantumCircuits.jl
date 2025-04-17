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

function mpirun(file::String, hosts::Vararg{String}; nice::Int=19, wait::Bool=true, julia_path::String=joinpath(Sys.BINDIR, Base.julia_exename()))
    # Check if the file exists
    if !isfile(file)
        error("File $file does not exist.")
    end
    run(`mpirun --bind-to none -np $(length(hosts)) -host $(hosts) nice -n $nice $(julia_path) -t auto --project $file`; wait)
end
end
# mpirun --bind-to none -np 2 -host l19,l90 nice -n 19 path/to/julia -t 20 --project file.jl
