### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try
            Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value
        catch
            b -> missing
        end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 9701cbe0-d048-11eb-151b-67dda7b72b71
begin
    import Pkg as _Pkg
    haskey(ENV, "PLUTO_PROJECT") && _Pkg.activate(ENV["PLUTO_PROJECT"]) # hide
    using Revise
    using PlutoVista
    using GridVisualize
    using ExtendableGrids
    using PlutoUI
    using HypertextLiteral
    GridVisualize.default_plotter!(PlutoVista)
end

# ╔═╡ f6205299-d097-4e78-8488-b088475191f6
let
    if isfile("plotting.jl")
        include("plotting.jl")
        plotting_multiscene(; Plotter = PlutoVista, resolution = (650, 300))
    end
end

# ╔═╡ 68e2c958-b417-4ba1-9577-697304fe140a
TableOfContents(; title = "")

# ╔═╡ b35d982d-1fa9-413d-b008-892b4f241097
md"""
# Test notebook for PlutoVista backend of GridVisualize
"""

# ╔═╡ 00b04f6b-34a6-4e30-9864-d273305281d4
md"""
## 1D scalar plot
"""

# ╔═╡ a20d74c9-16da-408a-b247-0c17321888f9
function testplot1()
    grid = simplexgrid(0:0.01:10)
    scalarplot(grid, map(sin, grid); resolution = (600, 200), markershape = :star5,
               markevery = 20, xlabel = "x", ylabel = "z", legend = :rt, label = "sin")
end

# ╔═╡ 33482af8-3542-4723-ae43-770a789b69b3
testplot1()

# ╔═╡ c4eeb06f-932e-4acc-8e5b-f2a7f9242a42
function testplot2(; t = 0)
    p = GridVisualizer(; resolution = (500, 200), legend = :rt, xlabel = "x")
    grid = simplexgrid(0:0.01:10)
    scalarplot!(p, grid, map(x -> sin(x - t), grid); color = :red, label = "sin(x-$(t))",
                linestyle = :dash)
    scalarplot!(p, grid, map(cos, grid); color = :green, clear = false, label = "cos",
                linestyle = :dashdot, linewidth = 3)
    reveal(p)
end

# ╔═╡ 84192945-d4b6-4949-8f06-d94e04a7a56d
testplot2()

# ╔═╡ 7fbaf93f-3cfb-47d0-8252-487e60ba3e54
md"""
### Changing data by re-creating a plot
"""

# ╔═╡ 63fe3259-7d79-40ec-98be-e0592e40ee6b
@bind t2 PlutoUI.Slider(0:0.1:5, show_value = true)

# ╔═╡ 4de6b5c9-4d2d-4bcb-bc88-c6f50a23f9b6
testplot2(; t = t2)

# ╔═╡ 2061e7fd-c740-4d4b-af5b-7a3a9444aafd
md"""
### Changing data by updating the plot

For this pattern, we observe a notable difference to other backends:  the plot with PlutoVista appears above the cell where the GridVisualizer is created instead of the cell where data are plotted. The reason is that for updating data, we need to have a visualization context which stays the same.
"""

# ╔═╡ f84beb4f-4136-4e5a-ba43-279b703fc75f
begin
    X2 = 0:0.001:10
    grid2 = simplexgrid(collect(X2))
    f2(t) = map((x) -> sin(x^2 - t), grid2)
end

# ╔═╡ 29fa4467-65ee-4dad-a660-5197864ddbdc
md"""
t4: $(@bind t4 PlutoUI.Slider(-10:0.1:10, default=0, show_value=true))
"""

# ╔═╡ c1278fb2-3e75-445f-893a-b8b8a7e931d3
p = GridVisualizer(; resolution = (600, 200), dim = 1, legend = :lt);

# ╔═╡ 661531f7-f740-4dd4-9a59-89ddff06ba5c
scalarplot!(p, X2, f2(t4); show = true, clear = true, color = :red, label = "t=$(t4)")

# ╔═╡ dda4599d-05a2-4131-899a-42a653a18b51
md"""
### Non-continuous functions
"""

# ╔═╡ 00b115d3-aa8e-43ef-be6b-3d9d7b42f8af
let
    X = 0:1:10
    g = simplexgrid(X)
    cellmask!(g, [0], [5], 2)
    g1 = subgrid(g, [1])
    g2 = subgrid(g, [2])

    vis = GridVisualizer(; color = :red, size = (600, 200))
    func1 = map((x) -> x, g1)
    func2 = map((x) -> -x, g2)
    func = map(x -> x^2 / 100, g)
    scalarplot!(vis,
                [g1, g2],
                g,
                [func1, func2];
                elevation = 0.1,
                clear = true,
                color = :red,)
    scalarplot!(vis,
                g,
                func;
                elevation = 0.1,
                clear = false,
                color = :green,)
    reveal(vis)
end

# ╔═╡ ed9b80e5-9678-4ba6-bb36-c2e0674ed9ba
md"""
## 1D grid plot 
"""

# ╔═╡ 9ce4f63d-cd96-48d7-a637-07cb84fa88ab
function testgridplot()
    grid = simplexgrid(0:1:10)
    cellmask!(grid, [0.0], [5], 2)
    bfacemask!(grid, [5], [5], 3)
    gridplot(grid; resolution = (600, 200), legend = :rt)
end

# ╔═╡ d503ee1e-1e1f-4235-b286-dc3137a2c96a
testgridplot()

# ╔═╡ ae1fe1ab-4a0e-4c80-bd6f-912201fb4bb4
md"""
## 2D Scalar plot
"""

# ╔═╡ d5258595-60e4-406f-a71e-69111cdad8b9
function testplot3()
    X = 0:0.1:10
    grid = simplexgrid(X, X)
    f = map((x, y) -> sin(x) * atan(y), grid)
    scalarplot(grid, f;
               resolution = (300, 300), limits = (-π / 2, π / 2))
end

# ╔═╡ 0998a9a7-d57a-476e-aacd-bee9396e9b8f
testplot3()

# ╔═╡ cefb38c1-159e-42db-8088-294573fcece2
md"""
### Changing data

Generally, as above, with Plutovista we need two cells - one with the graph shown, and a second one which triggers the modification.
"""

# ╔═╡ a9f4f98f-ec2f-42d6-88da-4a8a6f727e93
begin
    X = 0:0.05:10
    grid = simplexgrid(X, X)
    f(t) = map((x, y) -> sin(x - t) * atan(y) * cos((y - t)), grid)
end

# ╔═╡ faa59bbd-df1f-4c62-9a77-c4752c6a6df4
vis = GridVisualizer(; resolution = (300, 300), dim = 2);

# ╔═╡ 6f1707ed-79ab-42dc-8ad8-d66a9e1a65b3
md"""
t= $(@bind t PlutoUI.Slider(-10:0.1:10, default=0, show_value=true))
"""

# ╔═╡ 412c905f-050c-4b78-a66f-0d03978e7edf
scalarplot!(vis, grid, f(t); limits = (-π / 2, π / 2), show = true, levels = 5)

# ╔═╡ e3c5a486-ec9b-4010-901b-07f7ac997355
md"""
### Non-continuous functions
"""

# ╔═╡ 9b41e77b-e6b9-43b2-89ce-14a9c0eb1242
let
    X = 0:0.7:10
    g = simplexgrid(X, X)
    cellmask!(g, [0, 0], [5, 5], 2)
    g1 = subgrid(g, [1])
    g2 = subgrid(g, [2])

    func1 = map((x, y) -> x^2 + y, g1)
    func2 = map((x, y) -> (x + y^2), g2)
    scalarplot([g1, g2], g, [func1, func2])
end

# ╔═╡ e9bc2dae-c303-4063-9ea9-36f95f93371c
md"""
## 2D Grid plot
"""

# ╔═╡ 2b3cb0f4-0656-4981-bec6-48785caf2994
function testgridplot2d()
    X = -1:0.2:1
    grid = simplexgrid(X, X)
    gridplot(grid; resolution = (300, 300))
end

# ╔═╡ 1388c246-be49-4757-a2cc-a685642b6b37
testgridplot2d()

# ╔═╡ 5eee8f1d-49ca-4e95-bd14-fe415b0c15e5
md"""
## 3D Scalar plot

Here we use the possibility to update plots to allow moving isosurfaces and plane cuts.
"""

# ╔═╡ 0c99daca-f9a8-4116-867b-e13461c3e754
function grid3d(; n = 15)
    X = collect(0:(1 / n):1)
    g = simplexgrid(X, X, X)
end

# ╔═╡ 82ccfd24-0053-4399-9bc8-b2e4010bbc92
function func3d(; n = 15)
    g = grid3d(; n = n)
    g, map((x, y, z) -> sinpi(2 * x) * sinpi(3.5 * y) * sinpi(1.5 * z), g)
end

# ╔═╡ 8b20f720-5470-4da7-bbb6-b746e887046e
g3, f3 = func3d(; n = 31)

# ╔═╡ c0a0ea34-6fc3-4409-934e-086a1a36f94e
p3d = GridVisualizer(; resolution = (500, 500), dim = 3)

# ╔═╡ 35be5ef4-0664-4196-8f10-cf71ec7cb371
md"""
f: $(@bind flevel Slider(0:0.01:1,show_value=true,default=0.45))

x: $(@bind xplane Slider(0:0.01:1,show_value=true,default=0.45))
y: $(@bind yplane Slider(0:0.01:1,show_value=true,default=0.45))
z: $(@bind zplane Slider(0:0.01:1,show_value=true,default=0.45))
"""

# ╔═╡ ecd941a0-85b7-4bb7-a903-b19a500198e1
scalarplot!(p3d, g3, f3; levels = [flevel], xplanes = [xplane], yplanes = [yplane],
            zplanes = [zplane], colormap = :hot, outlinealpha = 0.05, show = true,
            levelalpha = 0.5)

# ╔═╡ d924d90d-4102-4ae8-b8de-254a17a5d4df
begin
    X4 = -1:0.1:1
    g4 = simplexgrid(X4, X4, X4)
end

# ╔═╡ 57ed5eea-bc1c-45eb-b4d3-dc63088db21a
scalarplot(g4, map((x, y, z) -> 0.01 * exp(-10 * (x^2 + y^2 + z^2)), g4); levels = 10)

# ╔═╡ 943da8f0-d18f-40d5-8158-a3ab5793112f
md"""
### Non-continuous functions
"""

# ╔═╡ ef973737-5cc3-4a3c-8859-a86d9c12c976
let
    X = 0:0.1:1
    g = simplexgrid(X, X, X)
    cellmask!(g, [0, 0, 0], [0.5, 0.5, 0.5], 2)
    g1 = subgrid(g, [1])
    g2 = subgrid(g, [2])
    func1 = map((x, y, z) -> (x + y + z), g1)
    func2 = map((x, y, z) -> (3 - x - y - z), g2)
    scalarplot([g1, g2],
               g,
               [func1, func2];
               levels = 0,
               yplane = 0.25,
               xplane = 0.25,
               zplane = 0.25,
               levelalpha = 1,
               colormap = :hot,)
end

# ╔═╡ 4b9113d2-10bd-4f7a-a2b8-22092656c6b3
md"""
## 3D grid plot
"""

# ╔═╡ f78196ca-d972-4fa6-bdc2-e76eba7ca5a1
p3dgrid = GridVisualizer(; resolution = (300, 300), dim = 3)

# ╔═╡ 7dd92757-c100-4158-baa8-1d9218c39aa7
md"""
x: $(@bind gxplane Slider(0:0.01:1,show_value=true,default=1.0))
y: $(@bind gyplane Slider(0:0.01:1,show_value=true,default=1.0))
z: $(@bind gzplane Slider(0:0.01:1,show_value=true,default=0.45))
"""

# ╔═╡ 840c80b7-5186-45a5-a8df-ec4fb50a5dbb
gridplot!(p3dgrid, g3; xplane = gxplane, yplane = gyplane, zplane = gzplane, show = true)

# ╔═╡ 4121e791-8785-472e-a706-7b9cefd36fd6
md"""
## 2D Vector plot
"""

# ╔═╡ e656dac5-466e-4c07-acfa-0478ad000cb2
function qv2d(; n = 20, stream = false, kwargs...)
    X = 0.0:(10 / (n - 1)):10

    f(x, y) = sin(x) * cos(y) + 0.05 * x * y
    fx(x, y) = -cos(x) * cos(y) - 0.05 * y
    fy(x, y) = sin(x) * sin(y) - 0.05 * x

    grid = simplexgrid(X, X)

    v = map(f, grid)
    ∇v = vcat(map(fx, grid)', map(fy, grid)')

    gvis = GridVisualizer(; resolution = (400, 400))
    scalarplot!(gvis, grid, v; colormap = :summer, levels = 7)
    vectorplot!(gvis, grid, ∇v; clear = false, show = true, kwargs...)
    reveal(gvis)
end

# ╔═╡ 812af347-7606-4c54-b155-88322d20d921
qv2d(; n = 50, spacing = 0.5)

# ╔═╡ 09998521-68b6-45b4-8c1d-ae73bbd431ad
md"""
## Arranging plots
"""

# ╔═╡ 2d31f310-0d59-4ceb-9daf-61f447de3bb0
let vis = GridVisualizer(; resolution = (600, 600), layout = (2, 2))
    g2 = simplexgrid(X, X)
    g3 = simplexgrid(X, X, X)
    scalarplot!(vis[1, 1], X, sin.(2 * X))
    scalarplot!(vis[1, 2], g2, (x, y) -> sin(x) * cos(y))
    scalarplot!(vis[2, 1], g2, (x, y) -> sin(x) * cos(y); colormap = :hot)
    scalarplot!(vis[2, 2], g2, (x, y) -> sin(x) * cos(y); colormap = :hot,
                backend = :plotly)
    reveal(vis)
end

# ╔═╡ 6915cc3e-ad9b-4721-9933-884cfc68a25a
md"""
It is also possible to arrange plots using HypertextLiteral:
"""

# ╔═╡ 49db8b25-50ce-4fb4-bea2-de8abfb53c56
X0 = 0:0.25:10

# ╔═╡ 15f4eeb3-c42e-449c-9161-f1df66de6cef
htl"""
<div style= "width: 800px; display: inline-block; white-space:nowrap;">
<div style= "display: inline-block;">
$(scalarplot(X0,X0,X0, (x,y,z)->(sin(x)*sin(y)*sin(z)*sqrt(x*y*z)),resolution=(200,200),colormap=:rainbow))
</div>
<div style= "display: inline-block;">
$(scalarplot(X0,X0,X0, (x,y,z)->(sin(0.1*x*y)*sin(z)),resolution=(200,200),colormap=:hot,backend=:plotly))
</div>
<div style= "display: inline-block;">
$(scalarplot(X0,X0, (x,y)->sin(0.1*x*y),resolution=(200,200),colormap=:summer))
</div>
<div style= "display: inline-block;">
$(scalarplot(X0, (x)->x*sin(2x),color=:red,resolution=(200,200),colormap=:summer))
</div>
</div>
"""

# ╔═╡ 75ffcd09-dfa8-42df-a3cd-a7e68786e73c
md"""
## Misc functionality + tests
"""

# ╔═╡ cf592b99-d596-4511-adbf-001145a59983
md"""
### Plotting of constants
"""

# ╔═╡ bc1c6d12-8d06-4f57-9044-8b5e86fd1c13
scalarplot(ones(10); size = (500, 200))

# ╔═╡ b9c9e4c8-9f4c-481c-bab6-f1baea33c108
md"""
### Aspect ratio handling
"""

# ╔═╡ 6a3b2356-e8a1-45f8-8648-2eca09a7b258
begin
    XX = 0:0.1:1
    YY = 0:0.1:10
end

# ╔═╡ 608a5704-a84c-4c55-8642-ecddb275dc1b
scalarplot(XX, YY, (x, y) -> sin(4x) * 10 * y; aspect = 0.1, xlabel = "aaa",
           size = (300, 300))

# ╔═╡ 3efbeb11-eaa4-4fc5-bd5f-b3bdb63e7772
scalarplot(XX, YY, (x, y) -> sin(4x) * 10 * y; aspect = 0.1, xlabel = "aaa",
           size = (300, 300), backend = :plotly)

# ╔═╡ ccd274d2-68c0-40e0-8ba7-b8421f5ec9d3
gridplot(simplexgrid(XX, YY); aspect = 0.1)

# ╔═╡ ba5111b8-0dca-42d2-970f-1e88f5392324
html"""<hr>"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ExtendableGrids = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
GridVisualize = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PlutoVista = "646e1f28-b900-46d7-9d87-d554eb38a413"
Revise = "295af30f-e4ad-537b-8983-00126c2a3abe"

[compat]
ExtendableGrids = "~1.1.0"
GridVisualize = "~1.1.7"
HypertextLiteral = "~0.9.4"
PlutoUI = "~0.7.52"
PlutoVista = "~1.0.1"
Revise = "~3.5.6"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "e16c3e55d1b87c5f4dccb5b049d023b943a3107e"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "76289dc51920fdc6e0013c872ba9551d54961c24"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.6.2"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bijections]]
git-tree-sha1 = "71281c0c28f97e0adeed24fdaa6bf7d37177f297"
uuid = "e2ed5e7c-b2de-5872-ae92-c73ca462fb04"
version = "0.1.5"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "c0216e792f518b39b22212127d4a84dc31e4e386"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.5"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "02aa26a4cf76381be7f66e020a3eddeb27b0a092"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.2"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "67c1f244b991cad9b0aa4b7540fb758c2488b129"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.24.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "8a62af3e248a8c4bad6b32cbbe663ae02275e32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+1"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c53fc348ca4d40d7b371e71fd52251839080cbc9"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.4"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.ElasticArrays]]
deps = ["Adapt"]
git-tree-sha1 = "e1c40d78de68e9a2be565f0202693a158ec9ad85"
uuid = "fdbdab4c-e67f-52f5-8c3f-e7b388dad3d4"
version = "1.2.11"

[[deps.ExtendableGrids]]
deps = ["AbstractTrees", "Bijections", "Dates", "DocStringExtensions", "ElasticArrays", "InteractiveUtils", "LinearAlgebra", "Printf", "Random", "Requires", "SparseArrays", "StaticArrays", "StatsBase", "Test", "WriteVTK"]
git-tree-sha1 = "3f0e26d8ba5603978daeb54aa02de4a52593c3f5"
uuid = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
version = "1.1.0"

    [deps.ExtendableGrids.extensions]
    ExtendableGridsGmshExt = "Gmsh"

    [deps.ExtendableGrids.weakdeps]
    Gmsh = "705231aa-382f-11e9-3f0c-b7cb4346fdeb"

[[deps.Extents]]
git-tree-sha1 = "5e1e4c53fa39afe63a7d356e30452249365fba99"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random"]
git-tree-sha1 = "a20eaa3ad64254c61eeb5f230d9306e937405434"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.6.1"
weakdeps = ["SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "2d6ca471a6c7b536127afccfa7564b5b39227fe0"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.5"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "d53480c0793b13341c40199190f92c611aa2e93c"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.3.2"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "Extents", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "424a5a6ce7c5d97cca7bcc4eac551b97294c54af"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.9"

[[deps.GridVisualize]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GeometryBasics", "GridVisualizeTools", "HypertextLiteral", "LinearAlgebra", "Observables", "OrderedCollections", "Printf", "StaticArrays"]
git-tree-sha1 = "4d0fc636d5989043aaa240d54284ef92e68f0879"
uuid = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
version = "1.1.7"

    [deps.GridVisualize.weakdeps]
    CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
    GLMakie = "e9467ef8-e4e7-5192-8a1a-b1aee30e663a"
    Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
    PlutoVista = "646e1f28-b900-46d7-9d87-d554eb38a413"
    PyPlot = "d330b81b-6aea-500a-939a-2ce795aea3ee"

[[deps.GridVisualizeTools]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "StaticArraysCore"]
git-tree-sha1 = "5c7c69e512b6b65cdbc52cdaae1c75a0e186087a"
uuid = "5573ae12-3b76-41d9-b48c-81d0b6e61cc5"
version = "0.3.1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IterTools]]
git-tree-sha1 = "4ced6667f9974fc5c5943fa5e2ef1ca43ea9e450"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.8.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "0592b1810613d1c95eeebcd22dc11fba186c2a57"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.26"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.LightXML]]
deps = ["Libdl", "XML2_jll"]
git-tree-sha1 = "e129d9391168c677cd4800f5c0abb1ed8cb3794f"
uuid = "9c8b4983-aa76-5018-a973-4c85ecc9e179"
version = "0.9.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "7d6dd4e9212aebaeed356de34ccf262a3cd415aa"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.26"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "60168780555f3e663c536500aa790b6368adc02a"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.3.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "6862738f9796b3edc1c09d0890afce4eca9e7e93"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.4"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+2"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e47cd150dbe0443c3a3651bc5b9cbd5576ab75b7"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.52"

[[deps.PlutoVista]]
deps = ["AbstractPlutoDingetjes", "ColorSchemes", "Colors", "DocStringExtensions", "GridVisualizeTools", "HypertextLiteral", "UUIDs"]
git-tree-sha1 = "5be7548065d668761814809e2c7ee33310a3d82f"
uuid = "646e1f28-b900-46d7-9d87-d554eb38a413"
version = "1.0.1"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "609c26951d80551620241c3d7090c71a73da75ab"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.6"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "c60ec5c62180f27efea3ba2908480f8055e17cee"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore"]
git-tree-sha1 = "0adf069a2a490c47273727e029371b31d44b72b2"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.6.5"
weakdeps = ["Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "1d77abd07f617c4868c33d4f5b9e1dbb2643c9cf"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.2"

[[deps.StructArrays]]
deps = ["Adapt", "ConstructionBase", "DataAPI", "GPUArraysCore", "StaticArraysCore", "Tables"]
git-tree-sha1 = "0a3db38e4cce3c54fe7a71f831cd7b6194a54213"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.16"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "a1f34829d5ac0ef499f6d84428bd6b4c71f02ead"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "b7a5e99f24892b6824a954199a45e9ffcc1c70f0"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.VTKBase]]
git-tree-sha1 = "c2d0db3ef09f1942d08ea455a9e252594be5f3b6"
uuid = "4004b06d-e244-455f-a6ce-a5f9919cc534"
version = "1.0.1"

[[deps.WriteVTK]]
deps = ["Base64", "CodecZlib", "FillArrays", "LightXML", "TranscodingStreams", "VTKBase"]
git-tree-sha1 = "7b46936613e41cfe1c6a5897d243ddcab8feabec"
uuid = "64499a7a-5c06-52f2-abe2-ccb03c286192"
version = "1.18.0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "24b81b59bd35b3c42ab84fa589086e19be919916"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.11.5+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╠═9701cbe0-d048-11eb-151b-67dda7b72b71
# ╠═68e2c958-b417-4ba1-9577-697304fe140a
# ╟─b35d982d-1fa9-413d-b008-892b4f241097
# ╟─00b04f6b-34a6-4e30-9864-d273305281d4
# ╠═a20d74c9-16da-408a-b247-0c17321888f9
# ╠═33482af8-3542-4723-ae43-770a789b69b3
# ╠═c4eeb06f-932e-4acc-8e5b-f2a7f9242a42
# ╠═84192945-d4b6-4949-8f06-d94e04a7a56d
# ╟─7fbaf93f-3cfb-47d0-8252-487e60ba3e54
# ╟─63fe3259-7d79-40ec-98be-e0592e40ee6b
# ╠═4de6b5c9-4d2d-4bcb-bc88-c6f50a23f9b6
# ╟─2061e7fd-c740-4d4b-af5b-7a3a9444aafd
# ╠═f84beb4f-4136-4e5a-ba43-279b703fc75f
# ╟─29fa4467-65ee-4dad-a660-5197864ddbdc
# ╠═c1278fb2-3e75-445f-893a-b8b8a7e931d3
# ╠═661531f7-f740-4dd4-9a59-89ddff06ba5c
# ╟─dda4599d-05a2-4131-899a-42a653a18b51
# ╠═00b115d3-aa8e-43ef-be6b-3d9d7b42f8af
# ╟─ed9b80e5-9678-4ba6-bb36-c2e0674ed9ba
# ╠═9ce4f63d-cd96-48d7-a637-07cb84fa88ab
# ╠═d503ee1e-1e1f-4235-b286-dc3137a2c96a
# ╟─ae1fe1ab-4a0e-4c80-bd6f-912201fb4bb4
# ╠═d5258595-60e4-406f-a71e-69111cdad8b9
# ╠═0998a9a7-d57a-476e-aacd-bee9396e9b8f
# ╟─cefb38c1-159e-42db-8088-294573fcece2
# ╠═a9f4f98f-ec2f-42d6-88da-4a8a6f727e93
# ╠═faa59bbd-df1f-4c62-9a77-c4752c6a6df4
# ╠═412c905f-050c-4b78-a66f-0d03978e7edf
# ╟─6f1707ed-79ab-42dc-8ad8-d66a9e1a65b3
# ╟─e3c5a486-ec9b-4010-901b-07f7ac997355
# ╠═9b41e77b-e6b9-43b2-89ce-14a9c0eb1242
# ╟─e9bc2dae-c303-4063-9ea9-36f95f93371c
# ╠═2b3cb0f4-0656-4981-bec6-48785caf2994
# ╠═1388c246-be49-4757-a2cc-a685642b6b37
# ╟─5eee8f1d-49ca-4e95-bd14-fe415b0c15e5
# ╠═0c99daca-f9a8-4116-867b-e13461c3e754
# ╠═82ccfd24-0053-4399-9bc8-b2e4010bbc92
# ╠═8b20f720-5470-4da7-bbb6-b746e887046e
# ╠═c0a0ea34-6fc3-4409-934e-086a1a36f94e
# ╟─35be5ef4-0664-4196-8f10-cf71ec7cb371
# ╠═ecd941a0-85b7-4bb7-a903-b19a500198e1
# ╠═d924d90d-4102-4ae8-b8de-254a17a5d4df
# ╠═57ed5eea-bc1c-45eb-b4d3-dc63088db21a
# ╟─943da8f0-d18f-40d5-8158-a3ab5793112f
# ╠═ef973737-5cc3-4a3c-8859-a86d9c12c976
# ╟─4b9113d2-10bd-4f7a-a2b8-22092656c6b3
# ╠═f78196ca-d972-4fa6-bdc2-e76eba7ca5a1
# ╟─7dd92757-c100-4158-baa8-1d9218c39aa7
# ╠═840c80b7-5186-45a5-a8df-ec4fb50a5dbb
# ╟─4121e791-8785-472e-a706-7b9cefd36fd6
# ╠═e656dac5-466e-4c07-acfa-0478ad000cb2
# ╠═812af347-7606-4c54-b155-88322d20d921
# ╟─09998521-68b6-45b4-8c1d-ae73bbd431ad
# ╠═2d31f310-0d59-4ceb-9daf-61f447de3bb0
# ╠═f6205299-d097-4e78-8488-b088475191f6
# ╟─6915cc3e-ad9b-4721-9933-884cfc68a25a
# ╟─49db8b25-50ce-4fb4-bea2-de8abfb53c56
# ╟─15f4eeb3-c42e-449c-9161-f1df66de6cef
# ╟─75ffcd09-dfa8-42df-a3cd-a7e68786e73c
# ╟─cf592b99-d596-4511-adbf-001145a59983
# ╠═bc1c6d12-8d06-4f57-9044-8b5e86fd1c13
# ╟─b9c9e4c8-9f4c-481c-bab6-f1baea33c108
# ╠═6a3b2356-e8a1-45f8-8648-2eca09a7b258
# ╠═608a5704-a84c-4c55-8642-ecddb275dc1b
# ╠═3efbeb11-eaa4-4fc5-bd5f-b3bdb63e7772
# ╠═ccd274d2-68c0-40e0-8ba7-b8421f5ec9d3
# ╟─ba5111b8-0dca-42d2-970f-1e88f5392324
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
