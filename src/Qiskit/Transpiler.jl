#TODO expand functionality. Qiskit passmanager and more.
function transpile!(circuit::QuantumCircuit, backend::IBMBackend; optimization::Integer=0)
    0 <= optimization <= 3 || throw(ArgumentError("Degree must be between 0 and 3"))
    circuit.python_interface = qiskit.compiler.transpile(circuit.python_interface, backend.python_interface, optimization_level=optimization)
end
