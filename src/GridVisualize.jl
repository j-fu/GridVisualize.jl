module GridVisualize


using ExtendableGrids
using DocStringExtensions
using ElasticArrays
using StaticArrays

using Colors
using ColorSchemes
using GeometryBasics
using LinearAlgebra


include("dispatch.jl")
include("common.jl")
include("pyplot.jl")
include("makie.jl")
include("vtkview.jl")
include("meshcat.jl")
include("plots.jl")


export scalarplot,scalarplot!
export gridplot,gridplot!
export save,reveal
export isplots,isvtkview,ispyplot,ismakie
export GridVisualizer, SubVis
export plottertype
export PyPlotType,MakieType,PlotsType,VTKViewType 

end
