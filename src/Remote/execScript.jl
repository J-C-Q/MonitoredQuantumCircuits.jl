
using MPI
using MonitoredQuantumCircuits
MPI.Init()
comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
world_size = MPI.Comm_size(comm)


# load MonitoredQuantumCircuits in serial because of conda lock (maybe this can be fixed)
# for id in 1:world_size
#     if id == rank
#         using MonitoredQuantumCircuits

#         println("Rank $(rank) ready")
#     end
#     MPI.Barrier(comm)
# end
using MonitoredQuantumCircuits
using JLD2
MPI.Barrier(comm)
# open the parameter file

file = jldopen("$(basename(@__FILE__))"[1:end-2] * "jld2", "r")

parameter = file["parameters"][rank+1]

exec = file["function"]

backend = file["backend"]

circuit = exec(parameter...)

execute(circuit, backend)
