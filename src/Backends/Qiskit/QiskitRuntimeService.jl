struct QiskitRuntimeService
    python_interface::PythonCall.Py

    function QiskitRuntimeService()
        _checkinit_qiskit()
        try
            runtimeService = qiskit_ibm_runtime.QiskitRuntimeService()
            new(runtimeService)
        catch
            throw(ArgumentError("Could not connect to IBM Quantum. Please provide an API key."))
        end
    end
    function QiskitRuntimeService(api_key::String)
        _checkinit_qiskit()
        qiskit_ibm_runtime.QiskitRuntimeService.save_account(token=api_key, set_as_default=true)
        runtimeService = qiskit_ibm_runtime.QiskitRuntimeService()

        new(runtimeService)
    end
end
function Base.getproperty(qc::QiskitRuntimeService, prop::Symbol)
    if prop == :python_interface
        return getfield(qc, prop)
    else
        getproperty(qc.python_interface, prop)
    end
end
activeAccount(qc::QiskitRuntimeService) = qc.active_account()
function backends(qc::QiskitRuntimeService; args...)
    backends = qc.backends(args...)
    return [IBMBackend(backend) for backend in backends]
end
function getBackend(qc::QiskitRuntimeService, name::String)
    backend = qc.get_backend(name)
    return IBMBackend(backend)
end
function least_buisy(qc::QiskitRuntimeService,nqubits::Integer)
    qc.least_busy(
    operational=true, simulator=false, min_num_qubits=nqubits
)
end
function get_job(job_id::String)
    _checkinit_qiskit()
    runtime = QiskitRuntimeService()
    job = runtime.job(job_id)
    if job == nothing
        throw(ArgumentError("Job with ID $job_id not found."))
    end
    return job
end

function Base.show(io::IO, ::MIME"text/plain", obj::QiskitRuntimeService)
    account_info = activeAccount(obj)
    println(io, "Channel: $(account_info["channel"])")
    println(io, "URL: $(account_info["url"])")
    token = pyconvert(String, account_info["token"])
    println(io, "Token: $(token[1:5])...$(token[end-5:end])")
end
