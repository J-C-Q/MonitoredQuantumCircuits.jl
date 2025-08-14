# Qubit Geometries

```@meta
CurrentModule = MonitoredQuantumCircuits
```

A **Geometry** defines the spatial arrangement and connectivity of qubits, typically represented as a graph structure. MonitoredQuantumCircuits.jl provides several commonly used geometries out of the box, facilitating the construction and analysis of quantum circuits on a variety of lattice types. Users may also implement custom geometries by following the [geometry interface](/interfaces/add_geometry.md).

## Available Geometries
::: info `ChainGeometry`

Represents a chain (one-dimensional) structure, supporting both periodic and open boundary conditions.

:::

::: info `HoneycombGeometry`

Represents a honeycomb lattice structure, supporting periodic boundary conditions.

:::

::: info `IBMQ_Falcon`

Represents the qubit geometry of the IBM Quantum QPU Falcon architecture.  

:::

---

## API Reference

```@docs; canonical=false
ChainGeometry
HoneycombGeometry
IBMQ_Falcon
```
