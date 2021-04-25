````@eval
using Markdown
Markdown.parse("""
$(read("../../README.md",String))
""")
````


## Documentation
The basic structure is to create a GridVisualizer `p` which allows to have a 
grid of subplots. The `visualize!` methods then plot into a subplot `p[i,j]`. 
Creation of a GridVisualizer takes a `Plotter` keyword argument, which allows to
pass the corresponding plotting module. Supported are:

- From the REPL: GLMakie, PyPlot, VTKView (linux only), Plots (no 3D, no unstructured grids)
- From Pluto notebooks: GLMakie, PyPlot, Plots, WGLMakie (experimental), MeshCat (experimental)

Instead of a  plotter module,  all correspondinf API funcitons  accept as well `Plotter=nothing`
instead of a module. In that case, all related plotting functions just return without 
performing any action. 

Note that functionality here mostly will be added on necessity, with a focus on GLMakie and PyPlot.


## API

```@autodocs
Modules = [GridVisualize]
Pages = ["dispatch.jl"]
```
