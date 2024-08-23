using JLD2
struct StimSimulator <: MonitoredQuantumCircuits.Backend
end

function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, ::StimSimulator; shots=1024, verbose::Bool=true)
    verbose && print("Transpiling circuit to Stim...")
    qc = MonitoredQuantumCircuits.translate(StimCircuit, circuit)
    verbose && println("✓")

    verbose && print("Initializing compile sampler...")
    sampler = CompileSampler(qc)
    verbose && println("✓")

    verbose && print("Simulating circuit...")
    stimResult = pyconvert(Vector{Vector{Bool}}, sample(sampler; shots))

    verbose && println("✓")
    return stimResult
end

function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, backend::StimSimulator, cluster::MonitoredQuantumCircuits.Remote.Cluster; shots=1024, verbose::Bool=true, email::String="", node::String="")
    JLD2.save("remotes/$(cluster.host_name)/simulation_$(hash(circuit)).jld2", "circuit", circuit, "backend", backend, "shots", shots)
    MonitoredQuantumCircuits.Remote.upload(cluster, "remotes/$(cluster.host_name)/simulation_$(hash(circuit)).jld2")
    # MonitoredQuantumCircuits.execute(circuit, backend, shots=shots, verbose=verbose)
end
