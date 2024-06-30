struct IBMBackend
    python_interface::Py
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
