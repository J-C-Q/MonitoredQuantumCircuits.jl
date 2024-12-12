# How to add a new operation?
Adding a new operation in MonitoredQuantumCircuits.jl is a bit more involved, since you have to implement the operation for every backend that you want to execute this operation in. 

## The basics
Independent of which backend you would like to support the operation, you need to implement a few functions. Firstly, you need to implement a type `MyOperation<:Operation` or `MyOperation<:MeasurementOperation` if your operation includes measurements. Next, there are some basic interfaces that the circuit construction logic relies on. Thus, please implement the following methods for your operations:

- `nQubits(::MyOperation)`
- `isClifford(::MyOperation)`
- `connectionGraph(::MyOperation)`
- `plotPositions(::MyOperation)`
- `color(::MyOperation)`
- `isAncilla(::MyOperation, qubit::Integer)`

## For each backend
For each backend that you want to support this operation, implement the following methods:

- 