# Operation Interface

It is possible to add custom operations to the MonitoredQuantumCircuits.jl framework. However, this process may require familiarity with each backend that should support your new operation.

## Basic Requirements

Regardless of the backend, you must implement a few essential methods. Begin by defining a new type, either as a subtype of `Operation` or `MeasurementOperation` (if your operation involves measurements). The circuit construction logic relies on the following interface methods, which must be implemented for your operation:

- `nQubits(::MyOperation)`  
  Specifies the number of qubits the operation acts upon.
- `isClifford(::MyOperation)`  
  Indicates whether the operation is a Clifford operation.

## Backend Integration

For each backend that should support your operation, you must implement the corresponding `apply!` method.

## Example

Below is an example implementation of the `Id` (identity) gate:

```julia
import MonitoredQuantumCircuits: Operation, nQubits, isClifford
import MonitoredQuantumCircuits: Qiskit, QuantumClifford, apply!

struct Id <: Operation end

nQubits(::Id) = 1
isClifford(::Id) = true

# Qiskit backend implementation
function apply!(qc::Qiskit.Circuit, ::Id, p, ::Integer)
    qc.id(p[1] - 1)
end

# QuantumClifford backend implementation
function apply!(
    register::QuantumClifford.QC.Register,
    ::QuantumClifford.TableauSimulator,
    ::Id,
    p
)
    QuantumClifford.QC.apply!(register, QuantumClifford.QC.sId1(p[1]))
end
```

By following this approach, you can ensure that your custom operation integrates seamlessly with the MonitoredQuantumCircuits.jl framework and is supported across the desired backends.