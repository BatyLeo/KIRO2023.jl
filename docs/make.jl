using KIRO2023
using Documenter

DocMeta.setdocmeta!(KIRO2023, :DocTestSetup, :(using KIRO2023); recursive=true)

makedocs(;
    modules=[KIRO2023],
    authors="Léo Baty and contributors",
    repo="https://github.com/BatyLeo/KIRO2023.jl/blob/{commit}{path}#{line}",
    sitename="KIRO2023.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://BatyLeo.github.io/KIRO2023.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=["Home" => "index.md"],
)

deploydocs(; repo="github.com/BatyLeo/KIRO2023.jl", devbranch="main")
