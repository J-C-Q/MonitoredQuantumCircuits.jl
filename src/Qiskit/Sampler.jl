struct Sampler
    python_interface::Py
    function Sampler(backend::String)
        new(qiskit_ibm_runtime.SamplerV2(backend=backend))
    end
    function Sampler(backend::IBMBackend)
        new(qiskit_ibm_runtime.SamplerV2(backend=backend.python_interface))
    end
    function Sampler(backend::AerSimulator)
        new(qiskit_ibm_runtime.SamplerV2(backend=backend.python_interface))
    end
end
function Base.getproperty(qc::Sampler, prop::Symbol)
    if prop == :python_interface
        return getfield(qc, prop)
    else
        getproperty(qc.python_interface, prop)
    end
end
Base.show(io::IO, ::MIME"text/plain", obj::Sampler) = print(io, obj.python_interface)

run(sampler::Sampler, qc::QuantumCircuit; shots=1024) = sampler.run([qc.python_interface], shots=shots)
