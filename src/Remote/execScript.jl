using MonitoredQuantumCircuits
using Serialization
using MPI

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

using JLD2
MPI.Barrier(comm)
# open the parameter file
exec = deserserialize(joinpath(@__DIR__, "$(ARGS[1])/$(ARGS[1]).jls"))
post = deserserialize(joinpath(@__DIR__, "$(ARGS[1])/$(ARGS[1])_post.jls"))
file = jldopen(joinpath(@__DIR__, "$(ARGS[1])/$(ARGS[1]).jld2"), "r")

parameter = file["parameters"][rank+1]

backend = file["backend"]
close(file)

circuit = exec(parameter...)

result = execute(circuit, backend)

JLD2.save(joinpath(@__DIR__, "$(ARGS[1])/data/$(parameter)_raw.jld2"), "parameter", parameter, "result", result)

final = post(result)

JLD2.save(joinpath(@__DIR__, "$(ARGS[1])/data/$(parameter).jld2"), "parameter", parameter, "result", final)
