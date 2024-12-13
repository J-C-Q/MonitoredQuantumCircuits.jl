# How to Add a New Backend?

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
Of course you could need more information passed to the `apply!` method. This can be handeled in the specific `execute` methode.

## Implement the `execute` method
Lastly, you have to implement a method that handles the execution (i.e. simulation or API requests to the quantum device). 

```julia
function execute(circuit::FiniteDepthCircuit, ::MyBackend)
    # logic goes here
end
```
This function should create an object of type `MyCircuit` and apply the gates from `circuit` using the implemented `apply!` methods.
Of course, you need to do this for every circuit type that you want to support with your backend. 

## Summary
In total, this could look like this
```julia
module MyBackendModule

import MonitoredQuantumCircuits: Simulator, FiniteDepthCircuit, apply!, execute

struct MyBackend <: Simulator end

# this could also be an already existing type if you are using a third package
struct MyCircuit
    # some attributes to store the circuit
end

function apply!(::MyCircuit, ::ZZ, p1::Integer, p2::Integer, p3::Integer)
    # apply z-basis parity measurement to qubits p1, p3 with p3 as ancilla qubit in the language of MyCircuit
end

function execute(circuit::FiniteDepthCircuit, ::MyBackend)
    mycircuit = MyCircuit()
    for operation in circuit
        apply!(mycircuit, operation[1], operation[2]...)
    end
end
end

```

