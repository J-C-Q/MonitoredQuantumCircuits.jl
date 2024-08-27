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
    ),
    source="src",
    build="build",
    pages=[
        "Home" => "index.md",
        "API" => "api.md",
        "Getting started" => "getting_started.md",
    ],

)

deploydocs(;
    repo="github.com/J-C-Q/MonitoredQuantumCircuits.jl",
    target="build",
    branch="gh-pages",
    devbranch="main",
    push_preview=true,
)
