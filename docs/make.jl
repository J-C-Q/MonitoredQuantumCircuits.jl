using Documenter, DocumenterVitepress
using MonitoredQuantumCircuits
makedocs(;
    sitename="MonitoredQuantumCircuits",
    authors="J-C-Q",
    modules=[MonitoredQuantumCircuits],
    warnonly=true,
    format=DocumenterVitepress.MarkdownVitepress(
        repo="github.com/J-C-Q/MonitoredQuantumCircuits.jl",
        devurl="dev",
        devbranch="main",
        assets=["assets/favicon.ico", "assets/logo.png", "assets/logo-square.png"]
    ),
    source="src",
    build="build",
    pages=[
        "Home" => "index.md",
        "Getting started" => "getting_started.md",
        "Library" => [
            "Geometries" => "library/lattices.md",
            "Operations" => "library/operations.md",
            "Circuits" => "library/circuits.md",
            "Backends" => [
                "Overview" => "library/backends.md",
                "Qiskit" => "library/qiskit.md",
                "QuantumClifford" => "library/quantumclifford.md"
            ]
        ],
        "Interfaces" => [
            "Geometry" => "interfaces/add_lattice.md",
            "Operation" => "interfaces/add_operation.md",
            "Circuit" => "interfaces/add_circuit.md",
            "Backend" => "interfaces/add_backend.md"
        ],
        "Modules" => [
            "GUI" => "modules/gui.md",
            "Remote" => "modules/remote.md"
        ],
        "API" => "api.md"],)
deploydocs(;
    repo="github.com/J-C-Q/MonitoredQuantumCircuits.jl",
    target="build",
    branch="gh-pages",
    devbranch="main",
    push_preview=true,
)
