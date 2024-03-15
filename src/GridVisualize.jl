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
using Interpolations: linear_interpolation
using IntervalSets

using GridVisualizeTools
using ChunkSplitters
using ExtendableGrids

include("griditerator.jl")
export LinearSimplices

include("dispatch.jl")
include("common.jl")
export quiverdata, vectorsample
include("pyplot.jl")
include("makie.jl")
include("vtkview.jl")
include("meshcat.jl")
include("plots.jl")
include("plutovista.jl")

export scalarplot, scalarplot!
export gridplot, gridplot!
export vectorplot, vectorplot!
export streamplot, streamplot!
export customplot, customplot!
export save, reveal, backend!
export isplots, isvtkview, ispyplot, ismakie, isplutovista
export GridVisualizer, SubVisualizer
export plottertype, available_kwargs
export default_plotter!, default_plotter
export PyPlotType, MakieType, PlotsType, VTKViewType, PlutoVistaType, MeshCatType
export movie

end
