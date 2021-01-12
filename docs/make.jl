ENV["MPLBACKEND"]="agg"
using Documenter, ExtendableGrids, Literate, GridVisualize
import PyPlot

example_md_dir  = joinpath(@__DIR__,"src","examples")

plotting=joinpath(@__DIR__,"..","examples","plotting.jl")
include(plotting)




include("makeplots.jl")



function mkdocs()

    Literate.markdown(plotting, example_md_dir, documenter=false,info=false)
    makeplots(example_md_dir)
    generated_examples=joinpath.("examples",filter(x->endswith(x, ".md"),readdir(example_md_dir)))
    makedocs(sitename="GridVisualize.jl",
    modules = [GridVisualize],
    doctest = false,
    clean = true,
             authors = "J. Fuhrmann",
             repo="https://github.com/j-fu/GridVisualize.jl",
             pages=[
                 "Home"=>"index.md",
                 "Examples" => generated_examples
             ])
end

mkdocs()

deploydocs(repo = "github.com/j-fu/GridVisualize.jl.git")

