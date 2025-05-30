
struct AerSimulator <: MQC.Simulator
    python_interface::PythonCall.Py
end
"""
    GPUStateVectorSimulator()

A Qiskit Aer statevector simulator that runs on the GPU.
"""
function GPUStateVectorSimulator()
    _checkinit_qiskit_aer(; gpu=true)
    AerSimulator(qiskit_aer.AerSimulator(
        method="statevector",
        device="GPU",
        cuStateVec_enable=true,
        enable_truncation=false,
        target=[0]
    ))
end

"""
    StateVectorSimulator()

A Qiskit Aer statevector simulator.
"""
function StateVectorSimulator()
    _checkinit_qiskit_aer()
    AerSimulator(qiskit_aer.AerSimulator(
        method="statevector",
        enable_truncation=false
    ))
end

"""
    CliffordSimulator()

A Qiskit Aer stabilizer simulator.
"""
function CliffordSimulator()
    _checkinit_qiskit_aer()
    AerSimulator(qiskit_aer.AerSimulator(method="stabilizer"))
end

"""
    GPUTensorNetworkSimulator()

A Qiskit Aer tensor network simulator that runs on the GPU.
"""
function GPUTensorNetworkSimulator()
    _checkinit_qiskit_aer(; gpu=true)
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

function MQC.execute(circuit::MQC.CompiledCircuit, backend::AerSimulator; shots=1024)
    verbose = false
    verbose && print("Transpiling circuit to Qiskit...")
    qc = translate(Circuit, circuit)
    verbose && println("✓")

    verbose && print("Transpiling circuit to backend...")
    transpile!(qc, backend)
    verbose && println("✓")

    verbose && print("Initializing sampler...")
    sampler = Sampler(backend)
    verbose && println("✓")

    verbose && print("Simulating circuit...")
    job = run(sampler, qc; shots)


    nativeResult = job.result()[0]
    verbose && println("✓")
    result = QiskitResult(nativeResult, circuit)

    # verbose && println("Job ID: $(job.job_id())")
    return result
end
