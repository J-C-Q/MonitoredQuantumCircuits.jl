
"""
    IBMBackend <: MonitoredQuantumCircuits.QuantumComputer

A Qiskit backend that runs on IBM's quantum computers.
"""
struct IBMBackend <: MQC.QuantumComputer
    python_interface::PythonCall.Py

    function IBMBackend(backend::PythonCall.Py)
        _checkinit_qiskit()
        new(backend)
    end

    function IBMBackend(name::String)
        _checkinit_qiskit()
        runtime = QiskitRuntimeService()
        backend = getBackend(runtime, name)
        new(backend)
    end
    function IBMBackend(name::String, api_key::String)
        _checkinit_qiskit()
        runtime = QiskitRuntimeService(api_key)
        backend = runtime.get_backend(name)
        new(backend)
    end
end
function Base.getproperty(qc::IBMBackend, prop::Symbol)
    if prop == :python_interface
        return getfield(qc, prop)
    else
        getproperty(qc.python_interface, prop)
    end
end

function Base.show(io::IO, ::MIME"text/plain", obj::IBMBackend)
    println(io, "Name: $(obj.name)")
    println(io, "Qubits: $(obj.num_qubits)")
    println(io, "Max shots: $(obj.max_shots)")
end

function execute(circuit::MQC.Circuit, backend::IBMBackend; verbose::Bool=true)
    verbose && print("Transpiling circuit to Qiskit...")
    qc = MQC.translate(QuantumCircuit, circuit)
    verbose && println("✓")

    verbose && print("Transpiling circuit to backend...")
    transpile!(qc, backend)
    verbose && println("✓")

    verbose && print("Initializing sampler...")
    sampler = Sampler(backend)
    verbose && println("✓")

    verbose && print("Submitting job...")
    job = run(sampler, qc)
    verbose && println("✓")

    verbose && println("Job ID: $(job.job_id())")
end

function isSimulator(::IBMBackend)
    return false
end
