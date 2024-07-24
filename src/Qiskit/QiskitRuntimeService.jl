struct QiskitRuntimeService
    python_interface::Py

    function QiskitRuntimeService()
        try
            runtimeService = qiskit_ibm_runtime.QiskitRuntimeService(channel="ibm_quantum")
            new(runtimeService)
        catch
            throw(ArgumentError("Could not connect to IBM Quantum. Please provide an API key."))
        end
    end
    function QiskitRuntimeService(api_key::String)
        runtimeService = qiskit_ibm_runtime.QiskitRuntimeService(token=api_key, channel="ibm_quantum")
        runtimeService.save_account(token=api_key, channel="ibm_quantum", overwrite=true)
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

function Base.show(io::IO, ::MIME"text/plain", obj::QiskitRuntimeService)
    account_info = activeAccount(obj)
    println(io, "Channel: $(account_info["channel"])")
    println(io, "URL: $(account_info["url"])")
    token = pyconvert(String, account_info["token"])
    println(io, "Token: $(token[1:5])...$(token[end-5:end])")
end
