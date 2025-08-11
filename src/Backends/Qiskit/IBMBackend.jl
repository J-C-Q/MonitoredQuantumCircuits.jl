
"""
    IBMBackend <: MonitoredQuantumCircuits.QuantumComputer

A Qiskit backend that runs on IBM's quantum computers.
"""
struct IBMBackend <: MQC.QuantumComputer
    python_interface::PythonCall.Py
    circuit::Circuit
    measurements::Vector{Bool}
    measured_qubits::Vector{Int64}
    nqubits::Int64
    ancillas::Int64

    function IBMBackend(backend::PythonCall.Py, nqubits::Integer; ancillas::Integer=0)
        _checkinit_qiskit()
        new(backend, Circuit(nqubits+ancillas+1,nqubits+ancillas+1),
         Bool[],
            Int64[],
            nqubits, ancillas+1)
    end

    function IBMBackend(nqubits::Integer; ancillas::Integer=0)
        _checkinit_qiskit()
        runtime = QiskitRuntimeService()
        backend = least_buisy(runtime,nqubits)
        new(backend, Circuit(nqubits+ancillas+1,nqubits+ancillas+1),
         Bool[],
            Int64[],
            nqubits, ancillas+1)
    end
    function IBMBackend(nqubits::Integer, api_key::String; ancillas::Integer=0)
        _checkinit_qiskit()
        runtime = QiskitRuntimeService(api_key)
        backend = least_buisy(runtime,nqubits)
        new(backend,Circuit(nqubits+ancillas+1,nqubits+ancillas+1),
         Bool[],
            Int64[],
            nqubits, ancillas+1)
    end
end
function Base.getproperty(qc::IBMBackend, prop::Symbol)
    if prop == :python_interface
        return getfield(qc, prop)
    else
        getproperty(qc.python_interface, prop)
    end
end

function get_circuit(backend::IBMBackend)
    return getfield(backend,:circuit)
end
function get_measurements(qc::IBMBackend)
    return getfield(qc, :measurements)
end
function get_measured_qubits(qc::IBMBackend)
    return getfield(qc, :measured_qubits)
end
function get_qubits(qc::IBMBackend)
    return getfield(qc, :nqubits)
end
function get_ancillas(qc::IBMBackend)
    return getfield(qc, :ancillas)
end
function get_measurements(qc::IBMBackend,shot::Integer)
    return @view getfield(qc, :measurements)[(shot-1)*length(get_measured_qubits(qc))+1:shot*length(get_measured_qubits(qc))]
end

function Base.show(io::IO, ::MIME"text/plain", obj::IBMBackend)
    println(io, "Name: $(obj.name)")
    println(io, get_circuit(obj).python_interface)
end

function MQC.execute!(backend::IBMBackend; shots=1)
    qc = get_circuit(backend)
    transpile!(qc, backend)
    sampler = Sampler(backend)
    job = run(sampler, qc)
    println("Job ID: $(job.job_id())")
end

function MQC.execute!(f::F,
    backend::IBMBackend, p;
    shots=1, kwargs...) where {F<:Function}

    @warn "execution for $(typeof(backend)) does not support post-processing functions. Use the function `postprocess!(jobId,p)` after the job is finished"

    return MQC.execute!(f, backend; shots=shots, kwargs...)
end

function MQC.execute!(f::F,
    backend::IBMBackend;
    shots=1, kwargs...) where {F<:Function}

    f()

    qc = get_circuit(backend)
    transpile!(qc, backend)
    sampler = Sampler(backend)


    if shots > 10000
        # batch the shots
        n_batches = ceil(Int, shots / 10000)
        batch_size = ceil(Int, shots / n_batches)
        circuit_copies = [
            deepcopy(qc) for _ in 1:n_batches
        ]

        job = run(sampler, circuit_copies; shots=batch_size)
        println("Job ID: $(job.job_id())")
    else
        job = run(sampler, qc; shots)
        println("Job ID: $(job.job_id())")
    end

    return backend
end




function postprocess!(backend::IBMBackend, jobId::String, p::P) where {P<:Function}
    _checkinit_qiskit()
    job = get_job(jobId)
    nativeResults = job.result()
    measurements = get_measurements(backend)
    measured_qubits = get_measured_qubits(backend)
    # measuring the same qubit again will overwrite the previous measurement
    # so we need to ensure that we only have unique measured qubits (the last measurement of a qubit is the one that counts)
    unique_measured_qubits = reverse!(unique!(reverse!(measured_qubits)))
    # empty!(measured_qubits)
    # append!(measured_qubits, unique_measured_qubits)

    for nativeResult in nativeResults
        bitstrings = PythonCall.pyconvert(Vector{String}, nativeResult.data.c.get_bitstrings())
        for bitstring in bitstrings
            meas = [c == '1' for c in reverse(bitstring)]
            for (i,m) in enumerate(measured_qubits)
                push!(measurements, meas[m])
            end
        end
    end
    index = 1
    for (j,nativeResult) in enumerate(nativeResults)
        for i in 1:PythonCall.pyconvert(Int64, nativeResult.data.c.num_shots)
            p(i+index-1)
        end
        index += PythonCall.pyconvert(Int64, nativeResult.data.c.num_shots)
    end
    return backend
end


function isSimulator(::IBMBackend)
    return false
end
