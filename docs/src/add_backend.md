# How to add a new backend?

MonitoredQuantumCircuits.jl allows you to add further backends, be it simulators or quantum devices. In general, it is recommended to create a module for each backend and import the necessary methods and types from MonitoredQuantumCircuits.jl into the namespace.

## Create a backend type
The first step is to create a type `MyBackend<:Simulator` if your backend is a simulator or  `MyBackend<:QuantumComputer` if your backend is a quantum device. This type does not have to contain any attributes (it can if that is necessary for your backend), but is solely used for dispatching the `execute` function.

## Create a quantum circuit type
The second step is to implement a type for a quantum circuit (e.g. `MyCircuit`) in the specific backend. This type stores all the information the backend execution needs to execute your quantum circuit and is used to dispatch the `apply!` method for each operation.

## Create `apply!` methods
Next, you need to implement the `apply!` methods for every operation that your backend should support. For example, for the `H` (Hadamard) operation, this could look like this
```julia
function apply!(::MyCircuit, ::H, position::Integer)
    # logic goes here
end
```
For the `ZZ` (parity measurement), this could look like this
```julia
function apply!(::MyCircuit, ::ZZ, p1::Integer, p2::Integer, p3::Integer)
    # logic goes here
end
```

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

import MonitoredQuantumCircuits: Simulator, FiniteDepthCircuit

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

