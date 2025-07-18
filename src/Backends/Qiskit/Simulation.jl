
struct AerSimulator <: MQC.Simulator
    python_interface::PythonCall.Py
    circuit::Circuit
end
"""
    GPUStateVectorSimulator()

A Qiskit Aer statevector simulator that runs on the GPU.
"""
function GPUStateVectorSimulator(nqubits::Integer)
    _checkinit_qiskit_aer(; gpu=true)
    AerSimulator(qiskit_aer.AerSimulator(
        method="statevector",
        device="GPU",
        cuStateVec_enable=true,
        enable_truncation=false,
        target=[0]),
        Circuit(nqubits+1,nqubits+1))
end

"""
    StateVectorSimulator()

A Qiskit Aer statevector simulator.
"""
function StateVectorSimulator(nqubits::Integer)
    _checkinit_qiskit_aer()
    AerSimulator(
        qiskit_aer.AerSimulator(
        method="statevector",
        enable_truncation=false),
        Circuit(nqubits+1,nqubits+1))
end

"""
    CliffordSimulator()

A Qiskit Aer stabilizer simulator.
"""
function CliffordSimulator(nqubits::Integer)
    _checkinit_qiskit_aer()
    AerSimulator(
        qiskit_aer.AerSimulator(method="stabilizer"),
        Circuit(nqubits+1,nqubits+1))
end

"""
    GPUTensorNetworkSimulator()

A Qiskit Aer tensor network simulator that runs on the GPU.
"""
function GPUTensorNetworkSimulator(nqubits::Integer)
    _checkinit_qiskit_aer(; gpu=true)
    AerSimulator(qiskit_aer.AerSimulator(
        method="tensor_network",
        device="GPU",
        cuStateVec_enable=true,
        use_cuTensorNet_autotuning=true,
        enable_truncation=false,
        target=[0]),
        Circuit(nqubits+1,nqubits+1))
end
function isSimulator(::AerSimulator)
    return true
end

function Base.show(io::IO, ::MIME"text/plain", obj::AerSimulator)
    println(io, get_circuit(obj).python_interface)
end

function Base.getproperty(qc::AerSimulator, prop::Symbol)
    if prop == :python_interface
        return getfield(qc, prop)
    else
        getproperty(qc.python_interface, prop)
    end
end

function get_circuit(qc::AerSimulator)
    return getfield(qc, :circuit)
end

function aux(backend::Union{AerSimulator,IBMBackend})
    # Ancilla qubit is the last qubit in the circuit
    return nQubits(get_circuit(backend))
end

function MQC.execute(backend::AerSimulator; shots=1)
    qc = get_circuit(backend)
    transpile!(qc, backend)
    sampler = Sampler(backend)
    job = run(sampler, qc; shots)
    nativeResult = job.result()[0]
    return nativeResult
end

