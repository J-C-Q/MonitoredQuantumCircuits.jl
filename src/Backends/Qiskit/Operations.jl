"""
    applyToQiskit(qc::Qiskit.QuantumCircuit, operation::Operation, position::Vararg{Integer})

Apply the operation to a Qiskit QuantumCircuit.
"""
function apply!(qc::QuantumCircuit, operation::MonitoredQuantumCircuits.Operation, ::Vararg{Integer})
    throw(ArgumentError("apply on $(typeof(qc)) not implemented for $(typeof(operation)). Please implement this method for your custom operation."))
end

function apply!(::QuantumCircuit, operation::MonitoredQuantumCircuits.Operation, ::Val, position::Vararg{Integer})
    throw(ArgumentError("operation  $(typeof(operation)) dosent have this many steps."))
end
