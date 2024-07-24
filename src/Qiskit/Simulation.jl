
struct AerSimulator <: Backend
    python_interface::Py
end
function QiskitSimulator()
    AerSimulator(qiskit_aer.AerSimulator())
end
function QiskitCliffordSimulator()
    AerSimulator(qiskit_aer.AerSimulator(method="stabilizer"))
end
function QiskitTensorNetworkSimulator()
    AerSimulator(qiskit_aer.AerSimulator(method="tensor_network"))
end
function isSimulator(::AerSimulator)
    return true
end

function Base.show(io::IO, ::MIME"text/plain", obj::AerSimulator)
    println(io, "AerSimulator")
end

function execute(circuit::Circuit, backend::AerSimulator; verbose::Bool=true)
    verbose && print("Transpiling circuit to Qiskit...")
    qc = convert(QuantumCircuit, circuit)
    verbose && println("✓")

    verbose && print("Transpiling circuit to backend...")
    transpile!(qc, backend)
    verbose && println("✓")

    verbose && print("Initializing sampler...")
    sampler = Sampler(backend)
    verbose && println("✓")

    verbose && print("Simulating circuit...")
    job = run(sampler, qc)
    verbose && println("✓")

    verbose && println("Job ID: $(job.job_id())")
    return job
end
