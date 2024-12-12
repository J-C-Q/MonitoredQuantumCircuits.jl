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
        "Interfaces" => [
            "Add a Geometry" => "add_lattice.md",
            "Add an Operation" => "add_operation.md",
            "Add a Circuit" => "add_circuit.md",
            "Add a Backend" => "add_backend.md"
        ],
        "Modules" => [
            "GUI" => "gui.md",
            "Remote" => "remote.md"
        ],
        "API" => "api.md"],)
deploydocs(;
    repo="github.com/J-C-Q/MonitoredQuantumCircuits.jl",
    target="build",
    branch="gh-pages",
    devbranch="main",
    push_preview=true,
)
