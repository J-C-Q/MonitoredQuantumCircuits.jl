![#MonitoredQuantumCircuits.jl](/docs/src/assets/logo.png#gh-light-mode-only "MonitoredQuantumCircuits.jl")
![#MonitoredQuantumCircuits.jl](/docs/src/assets/logo-dark.png#gh-dark-mode-only "MonitoredQuantumCircuits.jl")

<p align="center">
  <!-- <a href="https://J-C-Q.github.io/MonitoredQuantumCircuits.jl/stable/"><img src="https://img.shields.io/badge/docs-stable-blue.svg" alt="Stable"></a> -->
  <a href="https://J-C-Q.github.io/MonitoredQuantumCircuits.jl/dev/"><img src="https://img.shields.io/badge/docs-dev-blue.svg" alt="Dev"></a>  
  
</p>
<p align="center">
  <a href="https://github.com/J-C-Q/MonitoredQuantumCircuits.jl/actions/workflows/CI.yml?query=branch%3Amain"><img src="https://github.com/J-C-Q/MonitoredQuantumCircuits.jl/actions/workflows/CI.yml/badge.svg?branch=main" alt="Build Status"></a>
  <a href="https://codecov.io/gh/J-C-Q/MonitoredQuantumCircuits.jl"><img src="https://codecov.io/gh/J-C-Q/MonitoredQuantumCircuits.jl/branch/main/graph/badge.svg?token=UUCGN8AJKM" alt="Coverage"></a>
  <a href="https://github.com/JuliaTesting/Aqua.jl"><img src="https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg" alt="Aqua"></a>
</p>

## Overview

`MonitoredQuantumCircuits.jl` is a Julia package that simplifies research on quantum circuits focused on measurements. It offers an easy-to-use command line interface to create, simulate, and run (on IBM Quantum) quantum circuits  on various lattice geometries. The package is designed to be modular and extendable.

## Disclaimer

**Note:** This package is in the early stages of development. Features and interfaces are subject to change, and the package may not yet be fully stable.


## Installation

To install `MonitoredQuantumCircuits.jl`, use the Julia package manager with the following command:

```julia
using Pkg
Pkg.add("https://github.com/J-C-Q/MonitoredQuantumCircuits.jl.git")
```

## Usage example

You can get started by defining the lattice structure the circuit should be created on (currently supported are `HeavyChainLattice`, `HeavySquareLattice` and `HeavyHexagonLattice`).
```julia
using MonitoredQuantumCircuits

lattice = HeavyChainLattice(3)
```

Then create an empty circuit on it
```julia
circuit = EmptyCircuit(lattice)
```

You can now apply operations to the circuit, like so
```julia
apply!(circuit, ZZ(), 1, 2, 3)
```

Finally submit the circuit to be run on an IBM Quantum QPU
```julia
runIBMQ(circuit, "ibm_sherbrooke")
```
