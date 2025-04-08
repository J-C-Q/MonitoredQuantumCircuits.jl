# Backend Interface

MonitoredQuantumCircuits.jl allows you to integrate additional backends, including simulators or quantum devices. To streamline this process, it is recommended to create a dedicated module for each backend and import the required methods and types from MonitoredQuantumCircuits.jl into the module’s namespace.

## Create a Backend Type
Define a type `MyBackend <: Simulator` if your backend is a simulator, or `MyBackend <: QuantumComputer` if it represents a quantum device. This type primarily serves to dispatch the `execute` function and does not require attributes unless necessary for your implementation.

## Define a Quantum Circuit Type
Develop a type specific to your backend for representing quantum circuits (e.g., `MyCircuit`). This type encapsulates all the information required for backend execution and enables the dispatch of the `apply!` method for each operation.

## Implement `apply!` Methods
Define `apply!` methods for every operation your backend supports. For instance: 
### Example for a Hadamard Operation (`H`):
```julia
function apply!(::MyCircuit, ::H, position::Integer)
    # Backend-specific logic for applying a Hadamard gate
end
```
### Example for a Parity Measurement (`ZZ`):
```julia
function apply!(::MyCircuit, ::ZZ, p1::Integer, p2::Integer, p3::Integer)
    # Backend-specific logic for applying a Z-basis parity measurement
end
```
You can add additional parameters to the `apply!` method if required for specific operations. Just make sure to call the function correctly from `execute`.

## Implement the `execute` Method
Define the `execute` method to manage execution, whether by simulation or interaction with a quantum device’s API.

```julia
function execute(circuit::CompiledCircuit, ::MyBackend)
    # Instantiate a MyCircuit object
    mycircuit = MyCircuit()

    # Apply operations from the circuit
    for operation in circuit
        apply!(mycircuit, operation[1], operation[2]...)
    end

    # Additional execution logic, if necessary
end
```
The `execute` function initializes a circuit object of type `MyCircuit` and applies gates using the `apply!` methods you have implemented. Repeat this process for every circuit type your backend supports.

## Summary
Here is a complete example:
```julia
module MyBackendModule

import MonitoredQuantumCircuits: Simulator, FiniteDepthCircuit, apply!, execute

struct MyBackend <: Simulator end

# Define the circuit type (can reuse types from other packages if applicable)
struct MyCircuit
    # Attributes to represent the circuit
end

# Implement apply! methods
function apply!(::MyCircuit, ::ZZ, p1::Integer, p2::Integer, p3::Integer)
    # Logic for Z-basis parity measurement with p1, p2, and ancilla p3
end

# Implement execute
function execute(circuit::FiniteDepthCircuit, ::MyBackend)
    mycircuit = MyCircuit()
    for operation in circuit
        apply!(mycircuit, operation[1], operation[2]...)
    end
end
end

```

