using Documenter, DocumenterVitepress

using MonitoredQuantumCircuits

makedocs(;
    modules=[MonitoredQuantumCircuits],
    authors="Your Name Here",
    repo="https://github.com/J-C-Q/MonitoredQuantumCircuits.jl",
    sitename="MonitoredQuantumCircuits.jl",
    format=DocumenterVitepress.MarkdownVitepress(
        repo="https://github.com/J-C-Q/MonitoredQuantumCircuits.jl",
        devurl="dev",
        deploy_url="J-C-Q.github.io/MonitoredQuantumCircuits.jl",
        base="/MonitoredQuantumCircuits.jl/",
        # build_vitepress=false
    ),
    pages=[
        "Home" => "index.md",
    ],
    warnonly=true,
)

deploydocs(;
    repo="github.com/J-C-Q/MonitoredQuantumCircuits.jl",
    push_preview=true,
)
