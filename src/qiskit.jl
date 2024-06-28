module Qiskit
using PythonCall


# import qiskit at run time
const qiskit = PythonCall.pynew()
function __init__()
    PythonCall.pycopy!(qiskit, pyimport("qiskit"))
end
struct QuantumCircuit
    python_interface::Py
    QuantumCircuit(nQubits::Integer) = new(qiskit.QuantumCircuit(nQubits, nQubits))
end
function Base.getproperty(qc::QuantumCircuit, prop::Symbol)
    if prop == :python_interface
        return getfield(qc, prop)
    else
        getproperty(qc.python_interface, prop)
    end
end

Base.show(io::IO, ::MIME"text/plain", obj::QuantumCircuit) = print(io, obj.python_interface)

end
