GridVisualize
=============

Plotting companion module for [ExtendableGrids.jl](https://github.com/j-fu/ExtendableGrids.jl)
Provides grid and scalar piecewise linear function plotting for various plotting backends
on simplicial grids in one, two or three space dimensions.

General usage:

````
gridplot(grid, Plotter=PyPlot)
scalarplot(grid, function,Plotter=PyPlot)
````

For multiple plots in one plotting window, see the documentation.

Available plotting backends and functionality. 'i' means some
level of interactive control. '(y)' means avaliability only
on rectangular resp. cuboid grids.

|            | PyPlot | *Makie | Plots | VTKView |
|-----------:|--------|--------|-------|---------|
| scalar, 1D | y      | y      | y     | y       |
| grid, 1D   | y      | y      | y     | n       |
| scalar, 2D | y      | y,i    | (y)   | y,i     |
| grid, 2D   | y      | y,i    | (y)   | y,i     |
| scalar, 3D | y      | y,i    | no    | y,i     |
| grid, 3D   | y      | y,i    | no    | y,i     |

