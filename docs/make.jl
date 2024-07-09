using MonitoredQuantumCircuits
using Documenter

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
    repo="https://github.com/J-C-Q/MonitoredQuantumCircuits.jl/blob/{commit}{path}#{line}",
    sitename="MonitoredQuantumCircuits.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://J-C-Q.github.io/MonitoredQuantumCircuits.jl",
        repolink="https://github.com/J-C-Q/MonitoredQuantumCircuits.jl",
        edit_link="main",
        assets=String["assets/favicon.ico", "assets/style.css"],
        sidebar_sitename=false
    )
)

deploydocs(;
    repo="github.com/J-C-Q/MonitoredQuantumCircuits.jl.git",
    # devbranch="main"
)
