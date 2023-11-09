using MonitoredQuantumCircuits
using Documenter

DocMeta.setdocmeta!(MonitoredQuantumCircuits, :DocTestSetup, :(using MonitoredQuantumCircuits); recursive=true)

makedocs(;
    modules=[MonitoredQuantumCircuits],
    authors="Quinten Preiss",
    repo="https://github.com/J-C-Q/MonitoredQuantumCircuits.jl/blob/{commit}{path}#{line}",
    sitename="MonitoredQuantumCircuits.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://J-C-Q.github.io/MonitoredQuantumCircuits.jl",
        edit_link="main",
        assets=String[],
        sidebar_sitename=false
    ),
    pages=[
        "Home" => "index.md",
    ]
)

deploydocs(;
    repo="github.com/J-C-Q/MonitoredQuantumCircuits.jl",
    devbranch="main"
)
