# Graphical User Interface (GUI)

::: danger Disclaimer

The graphical user interface is currently under active development. Features and functionality are not yet fully implemented.

:::


MonitoredQuantumCircuits.jl provides a graphical user interface (GUI) designed to facilitate the construction and visualization of quantum circuits. The GUI aims to offer an intuitive, interactive environment for users to build and modify circuits without requiring direct manipulation of code.

## Usage

To launch the GUI, first create a circuit:

```julia
circuit = Circuit(lattice)
```

then, start the GUI with:

```julia
GUI.CircuitComposer!(circuit)
```

This command will open the interface in your default web browser.
