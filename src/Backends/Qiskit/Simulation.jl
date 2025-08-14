
abstract type AerSimulator <: MQC.Simulator end


"""
    StateVectorSimulator <: AerSimulator

A Qiskit Aer statevector simulator.
"""
struct StateVectorSimulator <: AerSimulator
    python_interface::PythonCall.Py
    circuit::Circuit
    measurements::Vector{Bool}
    measured_qubits::Vector{Int64}
    nqubits::Int64
    ancillas::Int64

    function StateVectorSimulator(nqubits::Integer; ancillas::Integer=0)
        _checkinit_qiskit_aer()
        new(qiskit_aer.AerSimulator(
            method="statevector",
            enable_truncation=false),
            Circuit(nqubits+ancillas+1,nqubits+ancillas+1),
            Bool[],
            Int64[],
            nqubits,
            ancillas+1)
    end
end
"""
    GPUStateVectorSimulator <: AerSimulator

A Qiskit Aer statevector simulator that runs on the GPU.
"""
struct GPUStateVectorSimulator <: AerSimulator
    python_interface::PythonCall.Py
    circuit::Circuit
    measurements::Vector{Bool}
    measured_qubits::Vector{Int64}
    nqubits::Int64
    ancillas::Int64

    function GPUStateVectorSimulator(nqubits::Integer; ancillas::Integer=0)
        _checkinit_qiskit_aer(; gpu=true)
        new(qiskit_aer.AerSimulator(
            method="statevector",
            device="GPU",
            cuStateVec_enable=true,
            enable_truncation=false,
            target=[0]),
            Circuit(nqubits+ancillas+1,nqubits+ancillas+1),
            Bool[],
            Int64[],
            nqubits,
            ancillas+1)
    end
end



"""
    CliffordSimulator <: AerSimulator

A Qiskit Aer stabilizer simulator.
"""
struct CliffordSimulator <: AerSimulator
    python_interface::PythonCall.Py
    circuit::Circuit
    measurements::Vector{Bool}
    measured_qubits::Vector{Int64}
    nqubits::Int64
    ancillas::Int64

    function CliffordSimulator(nqubits::Integer; ancillas::Integer=0)
        _checkinit_qiskit_aer()
        new(
            qiskit_aer.AerSimulator(method="stabilizer"),
            Circuit(nqubits+ancillas+1,nqubits+ancillas+1),
            Bool[],
            Int64[],
            nqubits,
            ancillas+1)
    end
end

"""
    GPUTensorNetworkSimulator <: AerSimulator

A Qiskit Aer tensor network simulator that runs on the GPU.
"""
struct GPUTensorNetworkSimulator <: AerSimulator
    python_interface::PythonCall.Py
    circuit::Circuit
    measurements::Vector{Bool}
    measured_qubits::Vector{Int64}
    nqubits::Int64
    ancillas::Int64

    function GPUTensorNetworkSimulator(nqubits::Integer; ancillas::Integer=0)
        _checkinit_qiskit_aer(; gpu=true)
        AerSimulator(qiskit_aer.AerSimulator(
            method="tensor_network",
            device="GPU",
            cuStateVec_enable=true,
            use_cuTensorNet_autotuning=true,
            enable_truncation=false,
            target=[0]),
            Circuit(nqubits+ancillas+1,nqubits+ancillas+1),
            Bool[],
            Int64[],
            nqubits,
            ancillas+1)
    end
end

function isSimulator(::AerSimulator)
    return true
end

function Base.show(io::IO, ::MIME"text/plain", obj::AerSimulator)
    println(io, "$(typeof(obj)) Backend powerd by Qiskit Aer")
    println(io, "Number of qubits: ", get_qubits(obj))
    println(io, "Number of ancillas: ", get_ancillas(obj))
    if !isempty(get_measured_qubits(obj))
        println(io, "Recorded measurements: ", length(get_measured_qubits(obj)))
    else
        println(io, "No measurements recorded.")
    end
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
function get_measurements(qc::AerSimulator)
    return getfield(qc, :measurements)
end
function get_measured_qubits(qc::AerSimulator)
    return getfield(qc, :measured_qubits)
end
function get_qubits(qc::AerSimulator)
    return getfield(qc, :nqubits)
end
function get_ancillas(qc::AerSimulator)
    return getfield(qc, :ancillas)
end
function get_measurements(qc::AerSimulator,shot::Integer)
    return @view getfield(qc, :measurements)[(shot-1)*length(get_measured_qubits(qc))+1:shot*length(get_measured_qubits(qc))]
end
function aux(backend::Union{AerSimulator,IBMBackend})
    # Ancilla qubit is the last qubit in the circuit
    return nQubits(get_circuit(backend))
end

function MQC.execute!(backend::AerSimulator; shots=1)
    qc = get_circuit(backend)
    transpile!(qc, backend)
    sampler = Sampler(backend)
    job = run(sampler, qc; shots)
    nativeResult = job.result()[0]
    measurements = get_measurements(backend)
    measured_qubits = get_measured_qubits(backend)
    # measuring the same qubit again will overwrite the previous measurement
    # so we need to ensure that we only have unique measured qubits (the last measurement of a qubit is the one that counts)
    unique_measured_qubits = reverse!(unique!(reverse!(measured_qubits)))
    # empty!(measured_qubits)
    # append!(measured_qubits, unique_measured_qubits)


    bitstrings = PythonCall.pyconvert(Vector{String}, nativeResult.data.c.get_bitstrings())
    for bitstring in bitstrings
        meas = [c == '1' for c in reverse(bitstring)]
        for (i,m) in enumerate(measured_qubits)
            push!(measurements, meas[m])
        end
    end
    return backend
end

function MQC.execute!(f::F,
    backend::AerSimulator, p::P=()->();
    shots=1, kwargs...) where {F<:Function,P<:Function}

    f()

    qc = get_circuit(backend)
    transpile!(qc, backend)
    sampler = Sampler(backend)
    job = run(sampler, qc; shots)
    nativeResult = job.result()[0]
    measurements = get_measurements(backend)
    measured_qubits = get_measured_qubits(backend)
    # measuring the same qubit again will overwrite the previous measurement
    # so we need to ensure that we only have unique measured qubits (the last measurement of a qubit is the one that counts)
    unique_measured_qubits = reverse!(unique!(reverse!(measured_qubits)))
    # empty!(measured_qubits)
    # append!(measured_qubits, unique_measured_qubits)
    bitstrings = PythonCall.pyconvert(Vector{String}, nativeResult.data.c.get_bitstrings())
    for bitstring in bitstrings
        meas = [c == '1' for c in reverse(bitstring)]
        for (i,m) in enumerate(measured_qubits)
            push!(measurements, meas[m])
        end
    end

    for i in 1:shots
        p(i)
    end

    return backend
end
