struct IBMBackend <: Backend
    python_interface::Py

    function IBMBackend(backend::Py)
        new(backend)
    end

    function IBMBackend(name::String)
        runtime = Qiskit.QiskitRuntimeService()
        backend = getBackend(runtime, name)
        new(backend)
    end
    function IBMBackend(name::String, api_key::String)
        runtime = Qiskit.QiskitRuntimeService(api_key)
        backend = getBackend(runtime, name)
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
