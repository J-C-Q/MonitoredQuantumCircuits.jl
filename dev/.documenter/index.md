


# MonitoredQuantumCircuits

Documentation for [MonitoredQuantumCircuits](https://github.com/J-C-Q/MonitoredQuantumCircuits.jl).
- [`MonitoredQuantumCircuits.XX`](#MonitoredQuantumCircuits.XX)
- [`MonitoredQuantumCircuits.YY`](#MonitoredQuantumCircuits.YY)
- [`MonitoredQuantumCircuits.ZZ`](#MonitoredQuantumCircuits.ZZ)
- [`MonitoredQuantumCircuits.EmptyCircuit`](#MonitoredQuantumCircuits.EmptyCircuit-Tuple{MonitoredQuantumCircuits.Lattice})
- [`MonitoredQuantumCircuits.apply!`](#MonitoredQuantumCircuits.apply!-Tuple{Circuit,%20MonitoredQuantumCircuits.Operation,%20Vararg{Integer}})
- [`MonitoredQuantumCircuits.apply!`](#MonitoredQuantumCircuits.apply!-Tuple{Circuit,%20Integer,%20MonitoredQuantumCircuits.Operation,%20Vararg{Integer}})
- [`MonitoredQuantumCircuits.applyToQiskit!`](#MonitoredQuantumCircuits.applyToQiskit!-Tuple{MonitoredQuantumCircuits.Qiskit.QuantumCircuit,%20MonitoredQuantumCircuits.Operation,%20Vararg{Integer}})
- [`MonitoredQuantumCircuits.connectionGraph`](#MonitoredQuantumCircuits.connectionGraph-Tuple{MonitoredQuantumCircuits.Operation})
- [`MonitoredQuantumCircuits.depth`](#MonitoredQuantumCircuits.depth-Tuple{MonitoredQuantumCircuits.Operation})
- [`MonitoredQuantumCircuits.isClifford`](#MonitoredQuantumCircuits.isClifford-Tuple{Circuit})
- [`MonitoredQuantumCircuits.isClifford`](#MonitoredQuantumCircuits.isClifford-Tuple{MonitoredQuantumCircuits.Operation})
- [`MonitoredQuantumCircuits.nQubits`](#MonitoredQuantumCircuits.nQubits-Tuple{MonitoredQuantumCircuits.Operation})

<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='MonitoredQuantumCircuits.XX' href='#MonitoredQuantumCircuits.XX'>#</a>&nbsp;<b><u>MonitoredQuantumCircuits.XX</u></b> &mdash; <i>Type</i>.




```julia
XX() <: Operation
```


A singelton type representing the XX operation.


[source](https://github.com/j-c-q/MonitoredQuantumCircuits.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='MonitoredQuantumCircuits.YY' href='#MonitoredQuantumCircuits.YY'>#</a>&nbsp;<b><u>MonitoredQuantumCircuits.YY</u></b> &mdash; <i>Type</i>.




```julia
YY() <: Operation
```


A singelton type representing the YY operation.


[source](https://github.com/j-c-q/MonitoredQuantumCircuits.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='MonitoredQuantumCircuits.ZZ' href='#MonitoredQuantumCircuits.ZZ'>#</a>&nbsp;<b><u>MonitoredQuantumCircuits.ZZ</u></b> &mdash; <i>Type</i>.




```julia
ZZ() <: Operation
```


A singelton type representing the ZZ operation.


[source](https://github.com/j-c-q/MonitoredQuantumCircuits.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='MonitoredQuantumCircuits.EmptyCircuit-Tuple{MonitoredQuantumCircuits.Lattice}' href='#MonitoredQuantumCircuits.EmptyCircuit-Tuple{MonitoredQuantumCircuits.Lattice}'>#</a>&nbsp;<b><u>MonitoredQuantumCircuits.EmptyCircuit</u></b> &mdash; <i>Method</i>.




```julia
EmptyCircuit(lattice::Lattice)
```


Create an empty circuit on the given lattice.


[source](https://github.com/j-c-q/MonitoredQuantumCircuits.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='MonitoredQuantumCircuits.apply!-Tuple{Circuit, Integer, MonitoredQuantumCircuits.Operation, Vararg{Integer}}' href='#MonitoredQuantumCircuits.apply!-Tuple{Circuit, Integer, MonitoredQuantumCircuits.Operation, Vararg{Integer}}'>#</a>&nbsp;<b><u>MonitoredQuantumCircuits.apply!</u></b> &mdash; <i>Method</i>.




```julia
apply!(circuit::Circuit, executionPosition::Integer, operation::Operation, position::Vararg{Integer})
```


Apply the given operation at a given execution time step at the given position(s) in the circuit. The executionPosition can be used to schedule multiple operations at the same time step. However it is important to first check if the operations are compatible with each other (as of now this will show a warning which can be muted with `mute=true`).


[source](https://github.com/j-c-q/MonitoredQuantumCircuits.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='MonitoredQuantumCircuits.apply!-Tuple{Circuit, MonitoredQuantumCircuits.Operation, Vararg{Integer}}' href='#MonitoredQuantumCircuits.apply!-Tuple{Circuit, MonitoredQuantumCircuits.Operation, Vararg{Integer}}'>#</a>&nbsp;<b><u>MonitoredQuantumCircuits.apply!</u></b> &mdash; <i>Method</i>.




```julia
apply!(circuit::Circuit, operation::Operation, position::Vararg{Integer})
```


Apply the given operation at the given position(s) in the circuit. Operations that act on more than one qubit need to have the same number of position arguments as qubits they act on, as well as a connection structure that is part of the lattice.


[source](https://github.com/j-c-q/MonitoredQuantumCircuits.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='MonitoredQuantumCircuits.applyToQiskit!-Tuple{MonitoredQuantumCircuits.Qiskit.QuantumCircuit, MonitoredQuantumCircuits.Operation, Vararg{Integer}}' href='#MonitoredQuantumCircuits.applyToQiskit!-Tuple{MonitoredQuantumCircuits.Qiskit.QuantumCircuit, MonitoredQuantumCircuits.Operation, Vararg{Integer}}'>#</a>&nbsp;<b><u>MonitoredQuantumCircuits.applyToQiskit!</u></b> &mdash; <i>Method</i>.




```julia
applyToQiskit(qc::Qiskit.QuantumCircuit, operation::Operation, position::Vararg{Integer})
```


Apply the operation to a Qiskit QuantumCircuit.


[source](https://github.com/j-c-q/MonitoredQuantumCircuits.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='MonitoredQuantumCircuits.connectionGraph-Tuple{MonitoredQuantumCircuits.Operation}' href='#MonitoredQuantumCircuits.connectionGraph-Tuple{MonitoredQuantumCircuits.Operation}'>#</a>&nbsp;<b><u>MonitoredQuantumCircuits.connectionGraph</u></b> &mdash; <i>Method</i>.




```julia
connectionGraph(operation::Operation)
```


Return a graph representing the unique gate connections of the operation.


[source](https://github.com/j-c-q/MonitoredQuantumCircuits.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='MonitoredQuantumCircuits.depth-Tuple{MonitoredQuantumCircuits.Operation}' href='#MonitoredQuantumCircuits.depth-Tuple{MonitoredQuantumCircuits.Operation}'>#</a>&nbsp;<b><u>MonitoredQuantumCircuits.depth</u></b> &mdash; <i>Method</i>.




```julia
depth(operation::Operation)
```


Return the depth of the operation.


[source](https://github.com/j-c-q/MonitoredQuantumCircuits.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='MonitoredQuantumCircuits.isClifford-Tuple{Circuit}' href='#MonitoredQuantumCircuits.isClifford-Tuple{Circuit}'>#</a>&nbsp;<b><u>MonitoredQuantumCircuits.isClifford</u></b> &mdash; <i>Method</i>.




```julia
isClifford(circuit::Circuit)
```


Check if the circuit is a Clifford circuit, i.e. only contains Clifford operations. Returns true if all operations are Clifford operations, false otherwise.


[source](https://github.com/j-c-q/MonitoredQuantumCircuits.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='MonitoredQuantumCircuits.isClifford-Tuple{MonitoredQuantumCircuits.Operation}' href='#MonitoredQuantumCircuits.isClifford-Tuple{MonitoredQuantumCircuits.Operation}'>#</a>&nbsp;<b><u>MonitoredQuantumCircuits.isClifford</u></b> &mdash; <i>Method</i>.




```julia
isClifford(operation::Operation)
```


Return whether the operation is a Clifford operation.


[source](https://github.com/j-c-q/MonitoredQuantumCircuits.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='MonitoredQuantumCircuits.nQubits-Tuple{MonitoredQuantumCircuits.Operation}' href='#MonitoredQuantumCircuits.nQubits-Tuple{MonitoredQuantumCircuits.Operation}'>#</a>&nbsp;<b><u>MonitoredQuantumCircuits.nQubits</u></b> &mdash; <i>Method</i>.




```julia
nQubits(operation::Operation)
```


Return the number of qubits the operation acts on.


[source](https://github.com/j-c-q/MonitoredQuantumCircuits.jl)

</div>
<br>
