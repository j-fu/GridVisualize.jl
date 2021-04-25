[![Build status](https://github.com/j-fu/GridVisualize.jl/workflows/linux-macos-windows/badge.svg)](https://github.com/j-fu/GridVisualize.jl/actions)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://j-fu.github.io/GridVisualize.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://j-fu.github.io/GridVisualize.jl/dev)

GridVisualize
=============

Plotting companion module for [ExtendableGrids.jl](https://github.com/j-fu/ExtendableGrids.jl)
Provides grid and scalar piecewise linear function plotting for various plotting backends
on simplicial grids in one, two or three space dimensions.

## General usage:

````
gridplot(grid, Plotter=PyPlot)
scalarplot(grid, function,Plotter=PyPlot)
````

For multiple plots in one plotting window, see the documentation.

## Available plotting backends and functionality.

- 'i' means some level of interactive control
- '(y)' means avaiability only on rectangular resp. cuboid grids.

|            | PyPlot | *Makie | Plots | VTKView |
|-----------:|--------|--------|-------|---------|
| scalar, 1D | y      | y      | y     | y       |
| grid, 1D   | y      | y      | y     | n       |
| scalar, 2D | y      | y,i    | (y)   | y,i     |
| grid, 2D   | y      | y,i    | (y)   | y,i     |
| scalar, 3D | y      | y,i    | no    | y,i     |
| grid, 3D   | y      | y,i    | no    | y,i     |



## [PyPlot](https://github.com/JuliaPy/PyPlot.jl):
![pyplot](docs/src/assets/multiscene_pyplot.png?raw=true)

## [Plots/gr](https://github.com/JuliaPlots/Plots.jl):
![plots](docs/src/assets/multiscene_plots.png?raw=true)

## [GLMakie](https://github.com/JuliaPlots/GLMakie.jl):
![glmakie](docs/src/assets/multiscene_glmakie.png?raw=true)

## [VTKView](https://github.com/j-fu/VTKView.jl):
![vtkview](docs/src/assets/multiscene_vtkview.png?raw=true)

