using Documenter, DocumenterVitepress

using MonitoredQunatumCircuits

makedocs(;
    modules=[MonitoredQunatumCircuits],
    authors="J-C-Q",
    repo="https://github.com/J-C-Q/MonitoredQunatumCircuits.jl",
    sitename="MonitoredQunatumCircuits.jl",
    format=DocumenterVitepress.MarkdownVitepress(
        repo="https://github.com/J-C-Q/MonitoredQunatumCircuits.jl",
        devurl="dev",
        deploy_url="J-C-Q.github.io/MonitoredQunatumCircuits.jl",
    ),
    pages=[
        "Home" => "index.md",
    ],
    warnonly=true,
)

deploydocs(;
    repo="github.com/J-C-Q/MonitoredQunatumCircuits.jl",
    push_preview=true,
)
