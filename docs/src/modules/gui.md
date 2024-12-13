# Graphical User Interface

MonitoredQuantumCircuits.jl offers a graphical user interface to construct quantum circuits. To use the interface, first create a circuit using the CLI
```julia
circuit = EmptyFiniteDepthCircuit(lattice)
```
then call
```julia
GUI.CircuitComposer!(circuit)
```
This will open a window in your default browser.