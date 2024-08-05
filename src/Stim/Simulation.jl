
struct StimSimulator <: Backend
end

function execute(circuit::Circuit, backend::StimSimulator; shots=1024, verbose::Bool=true)
    verbose && print("Transpiling circuit to Stim...")
    qc = translate(StimCircuit, circuit)
    verbose && println("✓")

    verbose && print("Initializing compile sampler...")
    sampler = CompileSampler(qc)
    verbose && println("✓")

    verbose && print("Simulating circuit...")
    job = sample(sampler; shots)
    verbose && println("✓")
    return job
end
