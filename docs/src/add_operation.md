# How to add a new operation?
Adding custom operation to the MonitoredQuantumCircuits.jl framework is also possible. I can however be a bit tricky since you have to be familiar with every backend that should support your new operation. 

## The basics
Independent of which backend you would like to support the operation, you need to implement a few functions. Firstly, you need to implement a type `MyOperation<:Operation` or `MyOperation<:MeasurementOperation` if your operation includes measurements. Next, there are some basic interfaces that the circuit construction logic relies on. Thus, please implement the following methods for your operation:

- `nQubits(::MyOperation)`
- `isClifford(::MyOperation)`
- `connectionGraph(::MyOperation)`
- `plotPositions(::MyOperation)`
- `color(::MyOperation)`
- `isAncilla(::MyOperation, qubit::Integer)`

## For each backend
For each backend that should support this operation, implement the `apply!` method.

## Example
Here is an example how one could implement the `Id` (identity) gate:
```julia
import MonitoredQuantumCircuits: Operation, nQubits, isClifford, connectionGraph, plotPositions, color, isAncilla
import MonitoredQuantumCircuits: Graphs
import MonitoredQuantumCircuits: Qiskit
import MonitoredQuantumCircuits: QuantumClifford
import MonitoredQuantumCircuits: apply!
struct Id <: Operation end

nQubits(::Id) = 1
isClifford(::Id) = true
connectionGraph(::Id) = Graphs.path_graph(1)
plotPositions(::Id) = [(0.0,0.0)]
color(::Id) = "#FFFFFF"
isAncilla(::Id, ::Integer) = false

function apply!(qc::Qiskit.QuantumCircuit, ::Id, pos::Integer)
    qc.id(pos - 1)
end
function apply!(qc::QuantumClifford.QC.Register, ::Id, pos::Integer)
    QuantumClifford.QC.apply!(qc, QuantumClifford.QC.sId1(p))
end

```