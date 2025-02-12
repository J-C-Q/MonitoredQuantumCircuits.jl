#TODO expand functionality. Qiskit passmanager and more.
function transpile!(circuit::Circuit, backend::IBMBackend; optimization::Integer=3)
    0 <= optimization <= 3 || throw(ArgumentError("Degree must be between 0 and 3"))
    circuit.python_interface = qiskit.compiler.transpile(circuit.python_interface, backend.python_interface, optimization_level=optimization)
end

function transpile!(circuit::Circuit, backend::AerSimulator; optimization::Integer=3)
    0 <= optimization <= 3 || throw(ArgumentError("Degree must be between 0 and 3"))
    circuit.python_interface = qiskit.compiler.transpile(circuit.python_interface, backend.python_interface, optimization_level=optimization)
end
