using Configurations
using IBMQClient.Schema
using UUIDs
function to_Qobj(circuit::GeneralQuantumCircuit; kw...)
    options = ExpOptions(; kw...)
    instructions = Vector{Instruction}(undef, length(circuit.locations))
    for (i, loc) in enumerate(circuit.locations)
        instructions[i] = generateInstruction(circuit.gates[circuit.gatePointer[i]], loc)
    end
    experiments = [Experiment(; header=options.exp_header, config=options.exp_config, instructions)]
    config = ExpConfig(shots=options.nshots, memory_slots=length(experiments))
    Qobj(;
        qobj_id=options.id,
        type="QASM",
        schema_version=v"1",
        options.header,
        experiments,
        config,
    )
end


function generateInstruction(gate::PreDefGate, locations::AbstractArray{Int64})
    return Gate(
        name=gate.name,
        qubits=locations,)
end



@option struct ExpOptions
    id::String = string(uuid1())
    header::Maybe{Dict{String,Any}} = nothing
    nshots::Int = 1024
    exp_header::Maybe{Vector{Dict{String,Any}}} = nothing
    exp_config::Maybe{Vector{Dict{String,Any}}} = nothing
end
