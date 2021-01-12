````@eval
using Markdown
Markdown.parse("""
$(read("../../README.md",String))
""")
````


## Documentation
The basic structure is to create a GridVisualizer `p` which allows to have a 
grid of subplots. The `visualize!` methods then plot into a subplot `p[i,j]`. 
Creation of a GridVisiualizer takes a `Plotter` keyword argument, which allow to
specify plotting module. Supported are:

- From the REPL: GLMakie, PyPlot, VTKView (linux only), Plots (no 3D, no unstructured)
- From Pluto notebooks: GLMakie PyPlot, Plots, WGLMakie (experimental), MeshCat (experimental)

Note   that    functionality   here   mostly   will    be   added   on
necessity.


## API

```@autodocs
Modules = [GridVisualize]
Pages = ["dispatch.jl"]
```
