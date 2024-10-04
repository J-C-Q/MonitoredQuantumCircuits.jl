struct Circuit{T<:Lattice,M<:Integer}
    lattice::T
    operations::Vector{Operation} # the (unique) operations
    operationPositions::Vector{Tuple{M,Vararg{M}}} # the position where the operations get applied
    operationPointers::Vector{M} # the pointer to which operation gets applied at the position
    executionOrder::Vector{M} # the order in which the operations get executed

    function Circuit(lattice::Lattice)
        M = Int64
        return new{typeof(lattice),M}(lattice, Operation[], Tuple{M,Vararg{M}}[], M[], M[])
    end
    function Circuit(lattice::Lattice, operations::Vector{Operation}, operationPositions::Vector{NTuple{N,M}}, operationPointers::Vector{M}, executionOrder::Vector{M}) where {M<:Integer,N}
        return new{typeof(lattice),M}(lattice, operations, operationPositions, operationPointers, executionOrder)
    end
end

"""
    EmptyCircuit(lattice::Lattice)

Create an empty circuit on the given lattice.
"""
EmptyCircuit(lattice::Lattice) = Circuit(lattice)
# """
#     NishimoriCircuit(lattice::Lattice)

# Create a Nishimori circuit on the given lattice, i.e. a circuit with one layer of ZZ operations on all bonds.
# """
# function NishimoriCircuit(lattice::Lattice)
#     operations = [ZZ()]

#     operationPositions = getBonds(lattice)
#     operationPointers = fill(1, length(operationPositions))
#     executionOrder = fill(1, length(operationPositions))
#     return Circuit(lattice, operations, operationPositions, operationPointers, executionOrder)
# end

"""
    apply!(circuit::Circuit, operation::Operation, position::Vararg{Integer})

Apply the given operation at the given position(s) in the circuit. Operations that act on more than one qubit need to have the same number of position arguments as qubits they act on, as well as a connection structure that is part of the lattice.
"""
function apply!(circuit::Circuit, operation::Operation, position::Vararg{Integer})
    _checkInBounds(circuit, operation, position...)

    if operation in circuit.operations
        index = findfirst([op == operation for op in circuit.operations])
    else
        push!(circuit.operations, operation)
        index = length(circuit.operations)
    end
    push!(circuit.operationPositions, position)
    push!(circuit.operationPointers, index)
    if isempty(circuit.executionOrder)
        push!(circuit.executionOrder, 1)
    else
        push!(circuit.executionOrder, maximum(circuit.executionOrder) + 1)
    end
    return circuit
end
"""
    apply!(circuit::Circuit, executionPosition::Integer, operation::Operation, position::Vararg{Integer})

Apply the given operation at a given execution time step at the given position(s) in the circuit. The executionPosition can be used to schedule multiple operations at the same time step. However it is important to first check if the operations are compatible with each other (as of now this will show a warning which can be muted with ```mute=true```).
"""
function apply!(circuit::Circuit, executionPosition::Integer, operation::Operation, position::Vararg{Integer}; mute::Bool=false)
    # TODO check if operation is compatible with other operations at the same execution position
    simultaniusOperations = _getOperations(circuit, executionPosition)
    if !mute && !isempty(simultaniusOperations)
        warmMessage = "Make sure that $operation at $position can be executed at the same time as \n"
        for operation in simultaniusOperations
            warmMessage *= "$(circuit.operations[circuit.operationPointers[operation]]) at $(circuit.operationPositions[operation])\n"
        end
        @warn warmMessage
    end
    circuit = apply!(circuit, operation, position...)
    circuit.executionOrder[end] = executionPosition
    return circuit
end


function _checkInBounds(circuit::Circuit, operation::Operation, position::Vararg{Integer})
    if length(position) != nQubits(operation)
        throw(ArgumentError("Invalid number of position arguments for operation. Expected $(nQubits(operation)), got $(length(position)) $(position)"))
    end
    if any([pos < 1 || pos > length(circuit.lattice) for pos in position])
        throw(ArgumentError("Invalid position argument for operation. Expected between 1 and $(length(circuit.lattice)), got $(position)"))
    end
    # check that the connectionGraph of the operation is a subgraph of the lattice graph between the given positions
    subgraph = induced_subgraph(circuit.lattice.graph, [position...])
    if !Graphs.Experimental.has_induced_subgraphisomorph(subgraph[1], connectionGraph(operation), vertex_relation=(g1, g2) -> g1 == g2)
        throw(ArgumentError("The connection graph of the operation is not a subgraph of the lattice graph between the given positions"))
    end
end

function Base.show(io::IO, circuit::Circuit)
    println(io, "$(typeof(circuit)):")
    if isempty(circuit.operationPointers)
        println(io, "No operations defined")
    else
        # as many execution steps as operations -> step count is redundant
        if all(circuit.executionOrder .== 1:length(circuit.executionOrder))
            # too many operations to show all
            if length(circuit.operationPointers) > 10
                println(io, "with $(length(circuit.operationPointers)) operations")
            else
                println(io, "Operations: ")
                for (i, ptr) in enumerate(circuit.operationPointers)
                    println(io, "  ", circuit.operations[ptr], " at ", circuit.operationPositions[i])
                end
            end
        else
            uniqueExecutionSteps = sort(unique(circuit.executionOrder))
            # too many operations to show all
            if length(circuit.operationPointers) > 10
                # print steps/step depending on if more than one step
                if length(uniqueExecutionSteps) > 1
                    println(io, "with $(length(circuit.operationPointers)) operations in $(length(uniqueExecutionSteps)) steps")
                else
                    println(io, "with $(length(circuit.operationPointers)) operations in 1 step")
                end
            else
                println(io, "Operations: ")
                for (i, step) in enumerate(uniqueExecutionSteps)
                    println(io, "  Step $step:")
                    operationsInStep = findall(circuit.executionOrder .== step)
                    for operation in operationsInStep
                        println(io, "    ", circuit.operations[circuit.operationPointers[operation]], " at ", circuit.operationPositions[operation])
                    end
                end
            end
        end

    end
end

function _getOperations(circuit::Circuit, executionPosition::Integer)
    operationsInStep = findall(circuit.executionOrder .== executionPosition)
    return operationsInStep
end
"""
    isClifford(circuit::Circuit)

Check if the circuit is a Clifford circuit, i.e. only contains Clifford operations.
Returns true if all operations are Clifford operations, false otherwise.
"""
function isClifford(circuit::Circuit)
    return all([isClifford(operation) for operation in circuit.operations])
end



# job.result()[0].data.c.get_counts().items()


function execute(::Circuit, backend::Backend; verbose::Bool=true)
    throw(ArgumentError("Backend $(typeof(backend)) not supported"))
end

function execute(generateCircuit::Function, parameters::Vector{T}, backend::Simulator, cluster::Remote.Cluster; ntasks_per_node=48, partition="", email="", account="", time="1:00:00") where {(T <: Tuple)}
    file = "remotes/$(cluster.host_name)/simulation_$(hash(generateCircuit))_$(hash(parameters)).jld2"
    JLD2.save(file, "function", generateCircuit, "parameters", parameters, "backend", backend)
    Remote.mkdir(cluster, "MonitoredQuantumCircuitsENV/simulation_$(hash(generateCircuit))_$(hash(parameters))/")
    Remote.upload(cluster, file, "MonitoredQuantumCircuitsENV/simulation_$(hash(generateCircuit))_$(hash(parameters))/")
    Remote.sbatchScript(
        "remotes/$(cluster.host_name)/",
        "simulation_$(hash(generateCircuit))_$(hash(parameters))",
        "execScript.jl";
        ntasks=length(parameters),
        nodes=ceil(Int64, length(parameters) / ntasks_per_node),
        ntasks_per_node=min(ntasks_per_node, length(parameters)),
        partition,
        email,
        account,
        time,
        load_juliaANDmpi_cmd=cluster.load_juliaANDmpi_cmd
    )
    Remote.upload(cluster, "remotes/$(cluster.host_name)/simulation_$(hash(generateCircuit))_$(hash(parameters)).sh", "MonitoredQuantumCircuitsENV/simulation_$(hash(generateCircuit))_$(hash(parameters))/")
    Remote.mkdir(cluster, "MonitoredQuantumCircuitsENV/simulation_$(hash(generateCircuit))_$(hash(parameters))/data/")
    Remote.queueJob(cluster, "MonitoredQuantumCircuitsENV/simulation_$(hash(generateCircuit))_$(hash(parameters))/simulation_$(hash(generateCircuit))_$(hash(parameters)).sh")
    Remote.getQueue(cluster)
end

# function execute(circuit::Circuit, backend::Simulator, cluster::Remote.Cluster;
#     shots=1024,
#     verbose::Bool=true,
#     nodes=1,
#     ntasks=1,
#     cpus_per_task=1,
#     mem_per_cpu="1G",
#     time="1:00:00",
#     partition="",
#     account="",
#     email="",
#     output="simulation_$(hash(circuit))_output.txt",
#     error="simulation_$(hash(circuit))_error.txt")

#     JLD2.save("remotes/$(cluster.host_name)/simulation_$(hash(circuit)).jld2", "circuit", circuit, "backend", backend, "shots", shots)
#     Remote.sbatchScript(
#         "remotes/$(cluster.host_name)/",
#         "simulation_$(hash(circuit))",
#         "execSkript.jl",
#         "/simulation_$(hash(circuit)).jld2";
#         use_mpi=false,
#         nodes,
#         ntasks,
#         cpus_per_task,
#         mem_per_cpu,
#         time,
#         partition,
#         account,
#         email,
#         output,
#         error)
#     Remote.mkdir(cluster, "MonitoredQuantumCircuitsENV/simulation_$(hash(circuit))/")
#     Remote.upload(cluster, "remotes/$(cluster.host_name)/simulation_$(hash(circuit)).jld2", "simulation_$(hash(circuit))/")
#     Remote.upload(cluster, "remotes/$(cluster.host_name)/simulation_$(hash(circuit)).sh", "simulation_$(hash(circuit))/")
#     Remote.queueJob(cluster, "MonitoredQuantumCircuitsENV/simulation_$(hash(circuit))/simulation_$(hash(circuit)).sh")
# end

function translate(type::Type, ::Circuit)
    throw(ArgumentError("Conversion from Circuit to $(typeof(type)) not supported"))
end

function save(name::String, circuit::Circuit)
    JLD2.save(name * ".jld2", "circuit", circuit)
end

function load(name::String)
    return JLD2.load(name * ".jld2", "circuit")
end

function loadMany(folder::String)
    files = [f for f in readdir(folder) if f[end-3:end] == ".jld2"]
    return [load(folder * "/" * f) for f in files]
end
