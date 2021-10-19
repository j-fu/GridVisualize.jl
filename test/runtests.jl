using Test, ExtendableGrids, GridVisualize
import PyPlot

@test true
if !Sys.isapple()
    plotting=joinpath(@__DIR__,"..","examples","plotting.jl")
    include(plotting)
    include("../docs/makeplots.jl")
    @testset "makeplots - PyPlot" begin
        makeplots(mktempdir(),Plotter=PyPlot)
    end
end
