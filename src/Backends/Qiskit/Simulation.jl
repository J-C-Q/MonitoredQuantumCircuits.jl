
struct AerSimulator <: MonitoredQuantumCircuits.Backend
    python_interface::Py
end
function GPUStateVectorSimulator()
    AerSimulator(qiskit_aer.AerSimulator(
        method="statevector",
        device="GPU",
        cuStateVec_enable=true,
        enable_truncation=false,
        target=[0]
    ))
end
function StateVectorSimulator()
    AerSimulator(qiskit_aer.AerSimulator(
        method="statevector",
        enable_truncation=false
    ))
end
function CliffordSimulator()
    AerSimulator(qiskit_aer.AerSimulator(method="stabilizer"))
end
function GPUTensorNetworkSimulator()
    AerSimulator(qiskit_aer.AerSimulator(
        method="tensor_network",
        device="GPU",
        cuStateVec_enable=true,
        use_cuTensorNet_autotuning=true,
        enable_truncation=false,
        target=[0]
    ))
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

function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, backend::AerSimulator; shots=1024, verbose::Bool=true)
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
    job = run(sampler, qc; shots)
    verbose && println("✓")

    verbose && println("Job ID: $(job.job_id())")
    return job
end

function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, backend::AerSimulator, cluster::MonitoredQuantumCircuits.Remote.Cluster; shots=1024, verbose::Bool=true, email::String="", node::String="")
    Remote.connect(cluster)

end
