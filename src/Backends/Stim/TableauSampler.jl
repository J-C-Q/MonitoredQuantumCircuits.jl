struct TableauSampler
    python_interface::Py
    function TableauSampler()
        new(stim.TableauSimulator())
    end
end
function Base.getproperty(qc::TableauSampler, prop::Symbol)
    if prop == :python_interface
        return getfield(qc, prop)
    else
        getproperty(qc.python_interface, prop)
    end
end
Base.show(io::IO, ::MIME"text/plain", obj::TableauSampler) = print(io, obj.python_interface)

sample(sampler::TableauSampler; shots=1024) = sampler.sample(shots=shots)
