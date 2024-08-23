
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
