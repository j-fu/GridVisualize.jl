using Test, ExtendableGrids, GridVisualize
import PyPlot, Plots, GLMakie

@test true
if !Sys.isapple()
    plotting=joinpath(@__DIR__,"..","examples","plotting.jl")
    include(plotting)
    include("../docs/makeplots.jl")
    @testset "makeplots - PyPlot" begin
        makeplots(mktempdir(),Plotter=PyPlot)
    end
    @testset "makeplots - Plots" begin
        makeplots(mktempdir(),Plotter=Plots)
    end
    @testset "makeplots - GLMakie" begin
        makeplots(mktempdir(),Plotter=GLMakie)
    end
end
