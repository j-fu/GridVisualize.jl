
# Plotting examples
# =================
# ## Plotters
#  All plot functions in GridVisualize.jl have a `Plotter` keyword argument
#  which defaults to `nothing`.  This allows to pass a module as plotting backend
#  without creating a dependency. Fully supported are `PyPlot` and `GLMakie`.
#  `WGLMakie` and `CairoMakie` work in principle but in the moment don't deliver
#  all necessary functionality.
# 
# Also supported is [`VTKView`](https://github.com/j-fu/VTKView.jl)  which is exeprimental and works only on linux
#
# Generally, grids and P1 FEM functions on grids can be plotted up to now.
#
# ## Grid plots
# Here, we define some sample grids for plotting purposes.

using ExtendableGrids
using GridVisualize

function grid1d(;n=50)
    X=collect(0:1/n:1)
    g=simplexgrid(X)
end

function grid2d(;n=20)
    X=collect(0:1/n:1)
    g=simplexgrid(X,X)
end

function grid3d(;n=15)
    X=collect(0:1/n:1)
    g=simplexgrid(X,X,X)
end

#
# Now, we can use the plot command of GridVisualize to plot grids
# Note the kwargs `xplane`, `yplane` and `zplane` which allow to control
# cutplanes which peel off some elements from the grid in 3d and allow to
# explore the inner triangulation.
#
# For Makie and VTKView, the cutplane values can be controlled interactively.
function plotting_grid3d(;Plotter=default_plotter(), kwargs...)
    gridplot(grid3d(); Plotter=Plotter, kwargs...)
end
# ![](plotting_grid3d.svg)


# ## Function plots
# Let us define some functions
function func1d(;n=50)
    g=grid1d(n=n)
    g,map(x->sinpi(2*x[1]),g)
end    

function func2d(;n=20)
    g=grid2d(n=n)
    g,map((x,y)->sinpi(2*x)*sinpi(3.5*y),g)
end

function func3d(;n=15)
    g=grid3d(n=n)
    g, map((x,y,z)->sinpi(2*x)*sinpi(3.5*y)*sinpi(1.5*z),g)
end    

#
# Plotting a function then goes as follows:
# `xplane`, `yplane` and `zplane` now define cut planes where
# the function projection is plotted as a heatmap.
# The additional `flevel` keyword argument allows
# to control an isolevel.
#
# For Makie and VTKView, the cutplane values and the flevel can be controlled interactively.
function plotting_func3d(;Plotter=default_plotter(), kwargs...)
    g,f=func3d()
    scalarplot(g,f; Plotter=Plotter, zplane=0.49,xplane=0.49,flevel=0.25, kwargs...)
end
# ![](plotting_func3d.svg)

# ## Multiscene plots
# We can combine multiple plots into one scene according to 
# some layout grid given by the layout parameter.
#
# The ',' key for GLMakie and the '*' key for VTKView allow to
# switch between gallery view (default) and focused view of only
# one subscene.
function plotting_multiscene(;Plotter=default_plotter())

    p=GridVisualizer(;Plotter=Plotter,layout=(2,3),clear=true,resolution=(800,500))
    gridplot!(p[1,1],grid1d(), title="1D grid")
    scalarplot!(p[2,1],grid1d(), sin, title="1D grid function", label="sin",markershape=:diamond,color=:red,legend=:rb)
    scalarplot!(p[2,1],grid1d(), cos, title="1D grid function", label="cos",linestyle=:dash,markershape=:none,color=:green,clear=false)
    gridplot!(p[1,2],grid2d(),title="2D grid")
    scalarplot!(p[2,2],func2d()...,colormap=:bamako,title="2D grid function")
    gridplot!(p[1,3],grid3d(),zplane=0.49,title="3D grid")
    scalarplot!(p[2,3],func3d()...,zplane=0.49,flevel=0.5,colormap=:bamako, title="3D grid function")
    reveal(p)
end
# ![](plotting_multiscene.svg)



