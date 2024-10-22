ENV["SKIP_CONDA_RESOLVE"] = "true"
using MonitoredQuantumCircuits
using Serialization
using MPI

MPI.Init()
comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
world_size = MPI.Comm_size(comm)

using JLD2

# open the parameter file
exec = deserialize(joinpath(@__DIR__, "$(ARGS[1])/$(ARGS[1]).jls"))
post = deserialize(joinpath(@__DIR__, "$(ARGS[1])/$(ARGS[1])_post.jls"))
file = jldopen(joinpath(@__DIR__, "$(ARGS[1])/$(ARGS[1]).jld2"), "r")

parameter = file["parameters"][rank+1]

backend = file["backend"]
close(file)

circuit = exec(parameter...)

result = execute(circuit, backend)

JLD2.save(joinpath(@__DIR__, "$(ARGS[1])/data/$(parameter)_$(rank+1)_raw.jld2"), "parameter", parameter, "result", result)

final = post(result)

JLD2.save(joinpath(@__DIR__, "$(ARGS[1])/data/$(parameter)_$(rank+1).jld2"), "parameter", parameter, "result", final)
