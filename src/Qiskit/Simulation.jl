
struct AerSimulator <: Backend
    python_interface::Py
end
function Simulator()
    AerSimulator(qiskit_aer.AerSimulator())
end
function CliffordSimulator()
    AerSimulator(qiskit_aer.AerSimulator(method="stabilizer"))
end
function TensorNetworkSimulator()
    AerSimulator(qiskit_aer.AerSimulator(method="tensor_network", device="GPU"))
end
function isSimulator(::AerSimulator)
    return true
end

function Base.show(io::IO, ::MIME"text/plain", obj::AerSimulator)
    println(io, "Name: $(obj.name)")
    println(io, "Qubits: $(obj.num_qubits)")
end

function Base.getproperty(qc::AerSimulator, prop::Symbol)
    if prop == :python_interface
        return getfield(qc, prop)
    else
        getproperty(qc.python_interface, prop)
    end
end

function execute(circuit::Circuit, backend::AerSimulator; verbose::Bool=true)
    verbose && print("Transpiling circuit to Qiskit...")
    qc = translate(QuantumCircuit, circuit)
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
