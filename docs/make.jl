ENV["MPLBACKEND"]="agg"
using Documenter, ExtendableGrids, Literate, GridVisualize
using GridVisualize.FlippableLayout
import PyPlot

plotting=joinpath(@__DIR__,"..","examples","plotting.jl")
include(plotting)




include("makeplots.jl")

example_md_dir  = joinpath(@__DIR__,"src","examples")


function mkdocs()
    
    Literate.markdown(plotting, example_md_dir, documenter=false,info=false)
 #   makeplots(example_md_dir)
#    generated_examples=joinpath.("examples",filter(x->endswith(x, ".md"),readdir(example_md_dir)))
    makedocs(sitename="GridVisualize.jl",
             modules = [GridVisualize],
             doctest = false,
             clean = false,
             authors = "J. Fuhrmann",
             repo="https://github.com/j-fu/GridVisualize.jl",
             pages=[
                 "Home"=>"index.md",
#                 "Examples" => generated_examples,
                 "Public API"=> "api.md",
                 "Private API"=> "privapi.md",
             ])
end

mkdocs()

deploydocs(repo = "github.com/j-fu/GridVisualize.jl.git",devbranch = "main")



