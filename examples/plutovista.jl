### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 9701cbe0-d048-11eb-151b-67dda7b72b71
using PlutoVista,GridVisualize,ExtendableGrids,PlutoUI

# ╔═╡ 68e2c958-b417-4ba1-9577-697304fe140a
TableOfContents()

# ╔═╡ b35d982d-1fa9-413d-b008-892b4f241097
md"""
# Test notebook for PlutoVista backend of GridVisualize
"""

# ╔═╡ 00b04f6b-34a6-4e30-9864-d273305281d4
md"""
## 1D scalar plot
"""

# ╔═╡ a20d74c9-16da-408a-b247-0c17321888f9
function testplot1(Plotter)
	grid=simplexgrid(0:0.01:10)	
	scalarplot(grid,map(sin,grid),Plotter=Plotter,resolution=(600,200),markershape=:star5,markevery=20, xlabel="x",ylabel="z",legend=:rt,label="sin")
end

# ╔═╡ 33482af8-3542-4723-ae43-770a789b69b3
testplot1(PlutoVista)

# ╔═╡ c4eeb06f-932e-4acc-8e5b-f2a7f9242a42
function testplot2(Plotter;t=0)
	p=GridVisualizer(Plotter=Plotter, resolution=(500,200),legend=:rt,xlabel="x")
	grid=simplexgrid(0:0.01:10)	
	scalarplot!(p,grid,map(x->sin(x-t),grid),Plotter=Plotter,color=:red,label="sin(x-$(t))",linestyle=:dash)
	scalarplot!(p,grid,map(cos,grid),Plotter=Plotter,color=:green,clear=false,label="cos",linestyle=:dashdot,linewidth=3)
	reveal(p)
end

# ╔═╡ 84192945-d4b6-4949-8f06-d94e04a7a56d
testplot2(PlutoVista)

# ╔═╡ 7fbaf93f-3cfb-47d0-8252-487e60ba3e54
md"""
### Changing data by re-creating a plot
"""

# ╔═╡ 63fe3259-7d79-40ec-98be-e0592e40ee6b
@bind t2 PlutoUI.Slider(0:0.1:5,show_value=true)

# ╔═╡ 4de6b5c9-4d2d-4bcb-bc88-c6f50a23f9b6
testplot2(PlutoVista,t=t2)

# ╔═╡ 2061e7fd-c740-4d4b-af5b-7a3a9444aafd
md"""
### Changing data by updating the plot

For this pattern, we observe a notable difference to other backends:  the plot with PlutoVista appears above the cell where the GridVisualizer is created instead of the cell where data are plotted. The reason is that for updating data, we need to have a visualization context which stays the same.
"""

# ╔═╡ f84beb4f-4136-4e5a-ba43-279b703fc75f
begin
	X2=0:0.001:10
	grid2=simplexgrid(collect(X2))
	f2(t)=map( (x)->sin(x^2-t),grid2)
end

# ╔═╡ 29fa4467-65ee-4dad-a660-5197864ddbdc
md"""
t4: $(@bind t4 PlutoUI.Slider(-10:0.1:10, default=0, show_value=true))
"""

# ╔═╡ c1278fb2-3e75-445f-893a-b8b8a7e931d3
p=GridVisualizer(Plotter=PlutoVista,resolution=(600,200),dim=1,legend=:lt);p

# ╔═╡ 661531f7-f740-4dd4-9a59-89ddff06ba5c
scalarplot!(p,X2,f2(t4),show=true,clear=true,color=:red,label="t=$(t4)")

# ╔═╡ ed9b80e5-9678-4ba6-bb36-c2e0674ed9ba
md"""
## 1D grid plot 
"""

# ╔═╡ 9ce4f63d-cd96-48d7-a637-07cb84fa88ab
function testgridplot(Plotter)
	grid=simplexgrid(0:1:10)
	cellmask!(grid,[0.0],[5],2)
	bfacemask!(grid,[5],[5],3)
	gridplot(grid, Plotter=Plotter,resolution=(600,200),legend=:rt)
end

# ╔═╡ 77eeefc7-e416-426b-8f87-1bc8439dae6d
testgridplot(PyPlot)

# ╔═╡ d503ee1e-1e1f-4235-b286-dc3137a2c96a
testgridplot(PlutoVista)

# ╔═╡ ae1fe1ab-4a0e-4c80-bd6f-912201fb4bb4
md"""
## 2D Scalar plot
"""

# ╔═╡ d5258595-60e4-406f-a71e-69111cdad8b9
function testplot3(Plotter)
	X=0:0.1:10
	grid=simplexgrid(X,X)
	f=map( (x,y)->sin(x)*atan(y),grid)
	scalarplot(grid,f,Plotter=Plotter,
		resolution=(300,300),limits=(-π/2,π/2))
end

# ╔═╡ 0998a9a7-d57a-476e-aacd-bee9396e9b8f
testplot3(PlutoVista)

# ╔═╡ cefb38c1-159e-42db-8088-294573fcece2
md"""
### Changing data

Generally, as above, with Plutovista we need two cells - one with the graph shown, and a second one which triggers the modification.
"""

# ╔═╡ a9f4f98f-ec2f-42d6-88da-4a8a6f727e93
begin
	X=0:0.05:10
	grid=simplexgrid(X,X)
	f(t)=map( (x,y)->sin(x-t)*atan(y)*cos((y-t)),grid)
end

# ╔═╡ faa59bbd-df1f-4c62-9a77-c4752c6a6df4
vis=GridVisualizer(resolution=(300,300),Plotter=PlutoVista,dim=2);vis

# ╔═╡ 6f1707ed-79ab-42dc-8ad8-d66a9e1a65b3
md"""
t= $(@bind t PlutoUI.Slider(-10:0.1:10, default=0, show_value=true))
"""

# ╔═╡ 412c905f-050c-4b78-a66f-0d03978e7edf
scalarplot!(vis,grid,f(t),limits=(-π/2,π/2),show=true,levels=5)

# ╔═╡ e9bc2dae-c303-4063-9ea9-36f95f93371c
md"""
## 2D Grid plot
"""

# ╔═╡ 2b3cb0f4-0656-4981-bec6-48785caf2994
function testgridplot2d(Plotter)
	X=-1:0.2:1
	grid=simplexgrid(X,X)
	gridplot(grid,Plotter=Plotter,resolution=(300,300))
end

# ╔═╡ 1388c246-be49-4757-a2cc-a685642b6b37
testgridplot2d(PlutoVista)

# ╔═╡ 5eee8f1d-49ca-4e95-bd14-fe415b0c15e5
md"""
## 3D Scalar plot

Here we use the possibility to update plots to allow moving isosurfaces and plane cuts.
"""

# ╔═╡ 0c99daca-f9a8-4116-867b-e13461c3e754
function grid3d(;n=15)
    X=collect(0:1/n:1)
    g=simplexgrid(X,X,X)
end

# ╔═╡ 82ccfd24-0053-4399-9bc8-b2e4010bbc92
function func3d(;n=15)
    g=grid3d(n=n)
    g, map((x,y,z)->sinpi(2*x)*sinpi(3.5*y)*sinpi(1.5*z),g)
end

# ╔═╡ 8b20f720-5470-4da7-bbb6-b746e887046e
g3,f3=func3d(n=101)

# ╔═╡ c0a0ea34-6fc3-4409-934e-086a1a36f94e
p3d=GridVisualizer(Plotter=PlutoVista,resolution=(500,500),dim=3);p3d

# ╔═╡ 35be5ef4-0664-4196-8f10-cf71ec7cb371
md"""
f: $(@bind flevel Slider(0:0.01:1,show_value=true,default=0.45))

x: $(@bind xplane Slider(0:0.01:1,show_value=true,default=0.45))
y: $(@bind yplane Slider(0:0.01:1,show_value=true,default=0.45))
z: $(@bind zplane Slider(0:0.01:1,show_value=true,default=0.45))
"""

# ╔═╡ ecd941a0-85b7-4bb7-a903-b19a500198e1
scalarplot!(p3d,g3,f3;levels=[flevel],xplanes=[xplane],yplanes=[yplane],zplanes=[zplane],colormap=:hot,outlinealpha=0.05,show=true,levelalpha=0.5)

# ╔═╡ d924d90d-4102-4ae8-b8de-254a17a5d4df
X4=-1:0.1:1; g4=simplexgrid(X4,X4,X4)

# ╔═╡ 57ed5eea-bc1c-45eb-b4d3-dc63088db21a
scalarplot(g4,map( (x,y,z)-> 0.01*exp(-10*(x^2+y^2+z^2)),g4),levels=5,Plotter=PlutoVista)

# ╔═╡ 4b9113d2-10bd-4f7a-a2b8-22092656c6b3
md"""
## 3D grid plot
"""

# ╔═╡ f78196ca-d972-4fa6-bdc2-e76eba7ca5a1
p3dgrid=GridVisualizer(Plotter=PlutoVista,resolution=(300,300),dim=3)

# ╔═╡ 7dd92757-c100-4158-baa8-1d9218c39aa7
md"""
x: $(@bind gxplane Slider(0:0.01:1,show_value=true,default=1.0))
y: $(@bind gyplane Slider(0:0.01:1,show_value=true,default=1.0))
z: $(@bind gzplane Slider(0:0.01:1,show_value=true,default=0.45))
"""

# ╔═╡ 840c80b7-5186-45a5-a8df-ec4fb50a5dbb
gridplot!(p3dgrid,g3; xplane=gxplane,yplane=gyplane,zplane=gzplane,show=true)

# ╔═╡ 4121e791-8785-472e-a706-7b9cefd36fd6
md"""
## 3D Vector plot
"""

# ╔═╡ e656dac5-466e-4c07-acfa-0478ad000cb2
function qv2d(;Plotter=nothing,n=20,stream=false,kwargs...)
	
    X=0.0:10/(n-1):10


    f(x,y)=sin(x)*cos(y)+0.05*x*y
    fx(x,y)=-cos(x)*cos(y)-0.05*y
    fy(x,y)=sin(x)*sin(y)-0.05*x
    
    
    grid=simplexgrid(X,X)
    

    v=map(f,grid)
    ∇v=vcat(map(fx,grid)',map(fy,grid)')

    gvis=GridVisualizer(Plotter=Plotter,resolution=(400,400))
    scalarplot!(gvis,grid,v,colormap=:summer,levels=7)
  	vectorplot!(gvis,grid,∇v;clear=false, show=true,kwargs...)
	reveal(gvis)
end

# ╔═╡ 812af347-7606-4c54-b155-88322d20d921
qv2d(Plotter=PlutoVista,n=50,spacing=0.5)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ExtendableGrids = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
GridVisualize = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PlutoVista = "646e1f28-b900-46d7-9d87-d554eb38a413"

[compat]
ExtendableGrids = "~0.8.3"
GridVisualize = "~0.3.6"
PlutoUI = "~0.7.16"
PlutoVista = "~0.8.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.0-rc1"
manifest_format = "2.0"

[[deps.AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.ElasticArrays]]
deps = ["Adapt"]
git-tree-sha1 = "a0fcc1bb3c9ceaf07e1d0529c9806ce94be6adf9"
uuid = "fdbdab4c-e67f-52f5-8c3f-e7b388dad3d4"
version = "1.2.9"

[[deps.ExtendableGrids]]
deps = ["AbstractTrees", "Dates", "DocStringExtensions", "ElasticArrays", "InteractiveUtils", "LinearAlgebra", "Printf", "Random", "SparseArrays", "Test"]
git-tree-sha1 = "85dbe70afc7153ad510577f158214b45be22593b"
uuid = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
version = "0.8.3"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[deps.GridVisualize]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GeometryBasics", "LinearAlgebra", "Observables", "OrderedCollections", "PkgVersion", "Printf", "Requires", "StaticArrays"]
git-tree-sha1 = "df7fe25b689ff995d29f5597161a9f95a1eb1171"
uuid = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
version = "0.3.6"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "f6532909bf3d40b308a0f360b6a0e626c0e263a8"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.1"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "98f59ff3639b3d9485a03a72f3ab35bab9465720"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.6"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

[[deps.PlutoUI]]
deps = ["Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "4c8a7d080daca18545c56f1cac28710c362478f3"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.16"

[[deps.PlutoVista]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "GridVisualize", "UUIDs"]
git-tree-sha1 = "ce59550b517ab41b5e687174f93f57c76f872b6d"
uuid = "646e1f28-b900-46d7-9d87-d554eb38a413"
version = "0.8.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
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
# ╠═ed9b80e5-9678-4ba6-bb36-c2e0674ed9ba
# ╠═9ce4f63d-cd96-48d7-a637-07cb84fa88ab
# ╠═77eeefc7-e416-426b-8f87-1bc8439dae6d
# ╠═d503ee1e-1e1f-4235-b286-dc3137a2c96a
# ╟─ae1fe1ab-4a0e-4c80-bd6f-912201fb4bb4
# ╠═d5258595-60e4-406f-a71e-69111cdad8b9
# ╠═0998a9a7-d57a-476e-aacd-bee9396e9b8f
# ╟─cefb38c1-159e-42db-8088-294573fcece2
# ╠═a9f4f98f-ec2f-42d6-88da-4a8a6f727e93
# ╠═faa59bbd-df1f-4c62-9a77-c4752c6a6df4
# ╠═412c905f-050c-4b78-a66f-0d03978e7edf
# ╟─6f1707ed-79ab-42dc-8ad8-d66a9e1a65b3
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
# ╟─4b9113d2-10bd-4f7a-a2b8-22092656c6b3
# ╠═f78196ca-d972-4fa6-bdc2-e76eba7ca5a1
# ╟─7dd92757-c100-4158-baa8-1d9218c39aa7
# ╠═840c80b7-5186-45a5-a8df-ec4fb50a5dbb
# ╟─4121e791-8785-472e-a706-7b9cefd36fd6
# ╠═e656dac5-466e-4c07-acfa-0478ad000cb2
# ╠═812af347-7606-4c54-b155-88322d20d921
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
