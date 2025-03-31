using Documenter, DocumenterVitepress
using MonitoredQuantumCircuits
makedocs(;
    sitename="MonitoredQuantumCircuits",
    authors="J-C-Q",
    modules=[MonitoredQuantumCircuits, MonitoredQuantumCircuits.Qiskit, MonitoredQuantumCircuits.QuantumClifford],
    warnonly=true,
    format=DocumenterVitepress.MarkdownVitepress(
        repo="github.com/J-C-Q/MonitoredQuantumCircuits.jl",
        devurl="dev",
        devbranch="main",
        assets=["/favicon.ico", "/favicon-96x96.png", "/favicon.svg", "/apple-touch-icon.png"],
        #local
        # md_output_path=".",
        # build_vitepress=false
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
        "API" => "api.md"],
    # clean=false
)

deploydocs(;
    repo="github.com/J-C-Q/MonitoredQuantumCircuits.jl",
    target="build",
    branch="gh-pages",
    devbranch="main",
    push_preview=true,
)
