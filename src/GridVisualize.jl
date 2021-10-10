module GridVisualize

using Printf
using LinearAlgebra

using DocStringExtensions
using OrderedCollections
using ElasticArrays
using StaticArrays
using Colors
using ColorSchemes
using GeometryBasics
using PkgVersion

using ExtendableGrids
using Requires



function __init__()
    # Set default backend depending on installed packages
    global default_backend=nothing
    @require Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" default_backend=Plots
    @require PyPlot = "d330b81b-6aea-500a-939a-2ce795aea3ee" default_backend=PyPlot
    @require GLMakie = "e9467ef8-e4e7-5192-8a1a-b1aee30e663a" default_backend=GLMakie
    @require PlutoVista = "646e1f28-b900-46d7-9d87-d554eb38a413" default_backend=PlutoVista
end





include("dispatch.jl")
include("common.jl")
include("pyplot.jl")
include("makie.jl")
include("vtkview.jl")
include("meshcat.jl")
include("plots.jl")
include("plutovista.jl")


export scalarplot,scalarplot!
export gridplot,gridplot!
export vectorplot,vectorplot!
export save,reveal,backend!
export isplots,isvtkview,ispyplot,ismakie,isplutovista
export GridVisualizer, SubVisualizer
export plottertype, available_kwargs
export default_plotter!, default_plotter
export PyPlotType,MakieType,PlotsType,VTKViewType, PlutoVistaType, MeshCatType

end
