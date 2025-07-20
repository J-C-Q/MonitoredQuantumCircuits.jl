function apply! end

function execute! end

function executeParallel end

function get_mpi_ref(input...)
    throw(ArgumentError("Load MPI.jl to use MPI"))
end
