struct CompileSampler
    python_interface::PythonCall.Py
    function CompileSampler(circuit::StimCircuit)
        _checkinit_stim()
        new(circuit.compile_sampler())
    end
end
function Base.getproperty(qc::CompileSampler, prop::Symbol)
    if prop == :python_interface
        return getfield(qc, prop)
    else
        getproperty(qc.python_interface, prop)
    end
end
Base.show(io::IO, ::MIME"text/plain", obj::CompileSampler) = print(io, obj.python_interface)

sample(sampler::CompileSampler; shots=1024) = sampler.sample(shots=shots)
