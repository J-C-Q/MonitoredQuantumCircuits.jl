using Documenter, DocumenterVitepress

using MonitoredQuantumCircuits

makedocs(;
    sitename="MonitoredQuantumCircuits.jl",
    favicon="assets/favicon.ico",
    authors="J-C-Q",
    modules=[MonitoredQuantumCircuits],
    warnonly=true,
    format=DocumenterVitepress.MarkdownVitepress(
        repo="github.com/J-C-Q/MonitoredQuantumCircuits.jl",
        devurl="dev",
        devbranch="main",
        assets=["assets/favicon.ico", "assets/logo.png", "assets/ssh-original.svg"]
    ),
    source="src",
    build="build",
    pages=[
        "Home" => "index.md",
        "Getting started" => "getting_started.md",
        "API" => "api.md",
        "GUI" => "gui.md",
        "Remote" => "remote.md",
        "Type Structure" => "type_structure.md"],)

deploydocs(;
    repo="github.com/J-C-Q/MonitoredQuantumCircuits.jl",
    target="build",
    branch="gh-pages",
    devbranch="main",
    push_preview=true,
)
