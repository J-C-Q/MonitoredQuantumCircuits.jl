abstract type Circuit end


"""
    FiniteDepthCircuit{T<:Lattice,M<:Integer} <: Circuit

A circuit that has a finite depth, i.e. a fixed number of time steps. The circuit is defined on a lattice of type T and can contain operations that act on multiple qubits as well as multiple operations at the same time step.
"""
struct FiniteDepthCircuit{T<:Lattice,M<:Integer} <: Circuit
    lattice::T
    operations::Vector{Operation} # the (unique) operations
    operationPositions::Vector{Tuple{M,Vararg{M}}} # the position where the operations get applied
    operationPointers::Vector{M} # the pointer to which operation gets applied at the position
    executionOrder::Vector{M} # the order in which the operations get executed

    function FiniteDepthCircuit(lattice::Lattice)
        M = Int64
        return new{typeof(lattice),M}(lattice, Operation[], Tuple{M,Vararg{M}}[], M[], M[])
    end
    function FiniteDepthCircuit(lattice::Lattice, operations::Vector{Operation}, operationPositions::Vector{NTuple{N,M}}, operationPointers::Vector{M}, executionOrder::Vector{M}) where {M<:Integer,N}
        return new{typeof(lattice),M}(lattice, operations, operationPositions, operationPointers, executionOrder)
    end
end

"""
    EmptyFiniteDepthCircuit(lattice::Lattice)

Create an empty circuit on the given lattice.
"""
EmptyFiniteDepthCircuit(lattice::Lattice) = FiniteDepthCircuit(lattice)


"""
    apply!(circuit::FiniteDepthCircuit, operation::Operation, position::Vararg{Integer})

Apply the given operation at the given position(s) in the circuit. Operations that act on more than one qubit need to have the same number of position arguments as qubits they act on, as well as a connection structure that is part of the lattice.
"""
function apply!(circuit::FiniteDepthCircuit, operation::Operation, position::Vararg{Integer})
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
    apply!(circuit::FiniteDepthCircuit, executionPosition::Integer, operation::Operation, position::Vararg{Integer})

Apply the given operation at a given execution time step at the given position(s) in the circuit. The executionPosition can be used to schedule multiple operations at the same time step. However it is important to first check if the operations are compatible with each other (as of now this will show a warning which can be muted with ```mute=true```).
"""
function apply!(circuit::FiniteDepthCircuit, executionPosition::Integer, operation::Operation, position::Vararg{Integer}; mute::Bool=false)
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


function _checkInBounds(circuit::FiniteDepthCircuit, operation::Operation, position::Vararg{Integer})
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

function Base.show(io::IO, circuit::FiniteDepthCircuit)
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

function _getOperations(circuit::FiniteDepthCircuit, executionPosition::Integer)
    operationsInStep = findall(circuit.executionOrder .== executionPosition)
    return operationsInStep
end

"""
    isClifford(circuit::FiniteDepthCircuit)

Check if the circuit is a Clifford circuit, i.e. only contains Clifford operations.
Returns true if all operations are Clifford operations, false otherwise.
"""
function isClifford(circuit::FiniteDepthCircuit)
    return all([isClifford(operation) for operation in circuit.operations])
end

"""
    execute(circuit::FiniteDepthCircuit, backend::Backend; verbose::Bool=true)

Execute the given circuit on the given backend. The backend needs to be a subtype of Backend. The verbose flag can be used to print additional information about individual execution steps.
"""
function execute(::FiniteDepthCircuit, backend::Backend; verbose::Bool=true)
    throw(ArgumentError("Backend $(typeof(backend)) not supported"))
end

# TODO: add circuits per tasks to compute multiple circuits in serial. This will also effect the batch script generation
"""
    execute(generateCircuit::Function, parameters::Vector{T}, backend::Simulator, cluster::Remote.Cluster; ntasks_per_node=48, partition="", email="", account="", time="1:00:00", postProcessing=() -> nothing, name="simulation", max_nodes=10) where {(T <: Tuple)}

Remotly execute multiple circuits in parallel. Each circuit should be generated by the the generateCircuit function give one entry of the parameters vector. The backend needs to be a subtype of Simulator. The cluster should have allready been initialized (see Remote).
"""
function execute(generateCircuit::Function, parameters::Vector{T}, backend::Simulator, cluster::Remote.Cluster; ntasks_per_node=48, partition="", email="", account="", time="1:00:00", postProcessing=() -> nothing, name="simulation", max_nodes=10) where {(T <: Tuple)}
    ntasks = length(parameters)
    if ntasks > max_nodes * ntasks_per_node
        println("Number of tasks $(ntasks) exceeds maximum number of tasks $(max_nodes * ntasks_per_node)! Scheduling multiple jobs")
    end
    Hash = hash(hash(generateCircuit) * hash(parameters))
    for i in 1:max(1, ceil(Int, ntasks / (ntasks_per_node * max_nodes)))
        start = (i - 1) * ntasks_per_node * max_nodes + 1
        stop = min(i * ntasks_per_node * max_nodes, ntasks)
        paras = parameters[start:stop]


        fullName = "$(name)_$(Hash)_$(start)_$(stop)"
        path = joinpath("remotes", fullName)
        mkpath(path)

        Serialization.serialize(joinpath(path, "generateCircuitFunction.jls"), generateCircuit)
        Serialization.serialize(joinpath(path, "postProcessingFunction.jls"), postProcessing)


        JLD2.save(joinpath(path, "dataAndBackend.jld2"), "parameters", paras, "backend", backend)

        Remote.sbatchScript(
            path,
            fullName,
            joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV", "execScript.jl");
            ntasks=min(length(paras), ntasks_per_node * max_nodes),
            nodes=ceil(Int64, length(paras) / ntasks_per_node),
            ntasks_per_node=min(ntasks_per_node, length(paras)),
            partition,
            email,
            account,
            time,
            load_juliaANDmpi_cmd=cluster.load_juliaANDmpi_cmd,
            dataDir=fullName
        )

        Remote.mkdir(cluster, joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV", fullName))
        Remote.mkdir(cluster, joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV", fullName, "data"))
        Remote.mkdir(cluster, joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV", fullName, "data_raw"))
        Remote.upload(cluster, joinpath(path, "generateCircuitFunction.jls"), joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV", fullName))
        Remote.upload(cluster, joinpath(path, "postProcessingFunction.jls"), joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV", fullName))
        Remote.upload(cluster, joinpath(path, "dataAndBackend.jld2"), joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV", fullName))
        Remote.upload(cluster, joinpath("remotes", fullName, "$(fullName).sh"), joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV", fullName))


        Remote.queueJob(cluster, "$(fullName).sh", joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV", fullName))
    end
    Remote.getQueue(cluster)
end

"""
    translate(type::Type, circuit::FiniteDepthCircuit)

Translate a given circuit to a given backend representation type.
"""
function translate(type::Type, ::FiniteDepthCircuit)
    throw(ArgumentError("Conversion from Circuit to $(typeof(type)) not supported"))
end

"""
    save(name::String, circuit::FiniteDepthCircuit)

Save the given circuit to a file with the given name.
"""
function save(name::String, circuit::FiniteDepthCircuit)
    JLD2.save(name * ".jld2", "circuit", circuit)
end

"""
    load(name::String)

Load a circuit from a file with the given name.
"""
function load(name::String)
    return JLD2.load(name * ".jld2", "circuit")
end

"""
    loadMany(folder::String)

Load all circuits from files in the given folder.
"""
function loadMany(folder::String)
    files = [f for f in readdir(folder) if f[end-3:end] == ".jld2"]
    return [load(folder * "/" * f) for f in files]
end

"""
    nMeasurements(circuit::FiniteDepthCircuit)

Get the number of measurements in the given circuit.
"""
function nMeasurements(circuit::FiniteDepthCircuit)
    total = 0
    for (i, operation) in enumerate(circuit.operations)
        measurements = nMeasurements(operation)
        if measurements > 0
            total += measurements * count(x -> x == i, circuit.operationPointers)
        end
    end
    return total
end

function measurements(circuit::FiniteDepthCircuit)
    qubits = zeros(Int, nMeasurements(circuit))



end

function Base.iterate(circuit::FiniteDepthCircuit, state::Int=1)
    if state <= depth(circuit)
        idx = findall(==(state), circuit.executionOrder)
        return Tuple{eltype(circuit.operations),eltype(circuit.operationPositions)}[(circuit.operations[circuit.operationPointers[i]], circuit.operationPositions[i]) for i in idx], state + 1
    else
        return nothing
    end
end

function depth(circuit::FiniteDepthCircuit)
    return length(unique(circuit.executionOrder))
end

Base.length(c::FiniteDepthCircuit) = depth(c)
"""
    RandomCircuit{T<:Lattice,M<:Integer} <: Circuit

A circuit that is generated randomly. The circuit is defined on a lattice of type T and can contain operations that act on multiple qubits as well as multiple operations at the same time step. The operations are chosen randomly from a given set of operations with a given probability.
"""
struct RandomCircuit{T<:Lattice,M<:Integer} <: Circuit
    lattice::T
    operations::Vector{Operation}
    probabilities::Vector{Float64}
    operationPositions::Vector{Vector{Tuple{M,Vararg{M}}}}
    depth::M

    function RandomCircuit(lattice::Lattice, operations::Vector{Operation}, probabilities::Vector{Float64}, operationPositions::Vector{Vector{NTuple{N,M}}}, depth::M) where {M<:Integer,N}
        return new{typeof(lattice),M}(lattice, operations, probabilities, operationPositions, depth)
    end
end
