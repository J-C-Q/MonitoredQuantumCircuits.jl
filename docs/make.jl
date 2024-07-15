using MonitoredQuantumCircuits
using Documenter, DocumenterVitepress

# DocMeta.setdocmeta!(MonitoredQuantumCircuits, :DocTestSetup, :(using MonitoredQuantumCircuits); recursive=true)

makedocs(;
    pages=[
        "Home" => "index.md",
        "Tutorial" => "tutorial.md",
        "API Reference" => "api.md",
    ],
    modules=[MonitoredQuantumCircuits],
    warnonly=true,
    authors="Quinten Preiss",
    repo="https://github.com/J-C-Q/MonitoredQuantumCircuits.jl",
    sitename="MonitoredQuantumCircuits.jl",
    format=DocumenterVitepress.MarkdownVitepress(
        # prettyurls=get(ENV, "CI", "false") == "true",
        # canonical="https://J-C-Q.github.io/MonitoredQuantumCircuits.jl",
        repo="https://github.com/J-C-Q/MonitoredQuantumCircuits.jl",
        # edit_link="main",
        # devurl="dev",
        # assets=String["assets/favicon.ico", "assets/style.css"],
        deploy_url="https://J-C-Q.github.io/MonitoredQuantumCircuits.jl"
    )
)

# deploydocs(;
#     repo="github.com/J-C-Q/MonitoredQuantumCircuits.jl.git",
#     # devbranch="main"
# )
