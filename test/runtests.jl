using Test, ExtendableGrids, GridVisualize
import PyPlot

@test true
if !Sys.isapple()
    plotting=joinpath(@__DIR__,"..","examples","plotting.jl")
    include(plotting)
    include("../docs/makeplots.jl")
    @test makeplots(mktempdir())
end
