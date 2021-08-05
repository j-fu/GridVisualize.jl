### A Pluto.jl notebook ###
# v0.15.1

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

# ╔═╡ 6df3beed-24a7-4b26-a315-0520f4863190
develop=false

# ╔═╡ 9701cbe0-d048-11eb-151b-67dda7b72b71
begin
   using Pkg
   Pkg.activate(mktempdir())
   Pkg.add("Revise")
   using Revise
   Pkg.add(["PyPlot","ExtendableGrids","PlutoUI","Plots"])
	if develop
	   Pkg.develop(["PlutoVista","GridVisualize"])
	else
	   Pkg.add(["PlutoVista","GridVisualize"])
	end
   using PyPlot,PlutoVista,GridVisualize,ExtendableGrids,PlutoUI,Plots
end

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

# ╔═╡ cc17187f-404c-4c31-8625-fa067eea7273
testplot1(PyPlot)

# ╔═╡ ad1c4dd6-7c6b-4433-a1ac-b2f817ba5d81
testplot1(Plots)

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

# ╔═╡ 29ca4775-6ba5-474c-bd2c-8f770b09addd
testplot2(PyPlot)

# ╔═╡ c0ab77e8-01ea-436d-85f2-34e253944f11
testplot2(Plots)

# ╔═╡ 84192945-d4b6-4949-8f06-d94e04a7a56d
testplot2(PlutoVista)

# ╔═╡ 63fe3259-7d79-40ec-98be-e0592e40ee6b
@bind t2 PlutoUI.Slider(0:0.1:5,show_value=true)

# ╔═╡ 4de6b5c9-4d2d-4bcb-bc88-c6f50a23f9b6
testplot2(PlutoVista,t=t2)

# ╔═╡ 2061e7fd-c740-4d4b-af5b-7a3a9444aafd
md"""
### Changeable data (experimental)

This just updates the data. In the 1D case the difference seems to be not critical.
"""

# ╔═╡ f84beb4f-4136-4e5a-ba43-279b703fc75f
begin
	X2=0:0.001:10
	grid2=simplexgrid(collect(X2))
	f2(t)=map( (x)->sin(x^2-t),grid2)
end

# ╔═╡ c1278fb2-3e75-445f-893a-b8b8a7e931d3
p=PlutoVista.PlutoVistaPlot(resolution=(600,200))

# ╔═╡ 29fa4467-65ee-4dad-a660-5197864ddbdc
md"""
t4: $(@bind t4 PlutoUI.Slider(-10:0.1:10, default=0, show_value=true))
"""

# ╔═╡ 661531f7-f740-4dd4-9a59-89ddff06ba5c
PlutoVista.plot!(p,X2,f2(t4))

# ╔═╡ 9bb243cc-c69a-405b-bb35-6cddfde8fd30
begin
	myplot(t)=scalarplot!(vis2,grid2,f2(t),show=true)
	vis2=GridVisualizer(resolution=(600,200),Plotter=PlutoVista,datadim=1)
end

# ╔═╡ f4c78c61-19b1-4889-aa20-c6a3b157d435
md"""
t3: $(@bind t3 PlutoUI.Slider(-10:0.1:10, default=0, show_value=true))
"""

# ╔═╡ be369a01-a0c2-4a6b-831b-f716cc807240
myplot(t3)

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
	scalarplot(grid,f,Plotter=Plotter,resolution=(300,300),flimits=(-π/2,π/2),backend=:vtk)
end

# ╔═╡ c98a90bf-1a3e-4681-a3b0-663c6844df6b
testplot3(PyPlot)

# ╔═╡ a0c3067b-3aa5-493e-b132-89746483b5ce
testplot3(Plots)

# ╔═╡ 0998a9a7-d57a-476e-aacd-bee9396e9b8f
testplot3(PlutoVista)

# ╔═╡ cefb38c1-159e-42db-8088-294573fcece2
md"""
### Changeable data (experimental)

Here we observe a more profound advantage, and vtk.js also has a rather understandable way how data can be updated.

Generally, with plutovista we need two cells - one with the graph shown, and a second one which triggers the modification.
"""

# ╔═╡ a9f4f98f-ec2f-42d6-88da-4a8a6f727e93
begin
	X=0:0.1:10
	grid=simplexgrid(X,X)
	f(t)=map( (x,y)->sin(x-t)*atan(y)*cos((y-t)),grid)
end

# ╔═╡ 412c905f-050c-4b78-a66f-0d03978e7edf
begin
	vis=GridVisualizer(resolution=(300,300),Plotter=PlutoVista)
	myplot2(t)=scalarplot!(vis,grid,f(t),show=true,flimits=(-π/2,π/2))
end

# ╔═╡ 6f1707ed-79ab-42dc-8ad8-d66a9e1a65b3
md"""
t= $(@bind t PlutoUI.Slider(-10:0.1:10, default=0, show_value=true))
"""

# ╔═╡ 461481ef-f88b-4e4e-b57d-ce003abbfdf1
myplot2(t)

# ╔═╡ Cell order:
# ╠═6df3beed-24a7-4b26-a315-0520f4863190
# ╠═9701cbe0-d048-11eb-151b-67dda7b72b71
# ╠═68e2c958-b417-4ba1-9577-697304fe140a
# ╟─b35d982d-1fa9-413d-b008-892b4f241097
# ╟─00b04f6b-34a6-4e30-9864-d273305281d4
# ╠═a20d74c9-16da-408a-b247-0c17321888f9
# ╠═cc17187f-404c-4c31-8625-fa067eea7273
# ╠═ad1c4dd6-7c6b-4433-a1ac-b2f817ba5d81
# ╠═33482af8-3542-4723-ae43-770a789b69b3
# ╠═c4eeb06f-932e-4acc-8e5b-f2a7f9242a42
# ╠═29ca4775-6ba5-474c-bd2c-8f770b09addd
# ╠═c0ab77e8-01ea-436d-85f2-34e253944f11
# ╠═84192945-d4b6-4949-8f06-d94e04a7a56d
# ╠═63fe3259-7d79-40ec-98be-e0592e40ee6b
# ╠═4de6b5c9-4d2d-4bcb-bc88-c6f50a23f9b6
# ╟─2061e7fd-c740-4d4b-af5b-7a3a9444aafd
# ╠═f84beb4f-4136-4e5a-ba43-279b703fc75f
# ╠═c1278fb2-3e75-445f-893a-b8b8a7e931d3
# ╠═661531f7-f740-4dd4-9a59-89ddff06ba5c
# ╟─29fa4467-65ee-4dad-a660-5197864ddbdc
# ╠═9bb243cc-c69a-405b-bb35-6cddfde8fd30
# ╠═be369a01-a0c2-4a6b-831b-f716cc807240
# ╟─f4c78c61-19b1-4889-aa20-c6a3b157d435
# ╠═ed9b80e5-9678-4ba6-bb36-c2e0674ed9ba
# ╠═9ce4f63d-cd96-48d7-a637-07cb84fa88ab
# ╠═77eeefc7-e416-426b-8f87-1bc8439dae6d
# ╠═d503ee1e-1e1f-4235-b286-dc3137a2c96a
# ╟─ae1fe1ab-4a0e-4c80-bd6f-912201fb4bb4
# ╠═d5258595-60e4-406f-a71e-69111cdad8b9
# ╠═c98a90bf-1a3e-4681-a3b0-663c6844df6b
# ╠═a0c3067b-3aa5-493e-b132-89746483b5ce
# ╠═0998a9a7-d57a-476e-aacd-bee9396e9b8f
# ╟─cefb38c1-159e-42db-8088-294573fcece2
# ╠═a9f4f98f-ec2f-42d6-88da-4a8a6f727e93
# ╠═412c905f-050c-4b78-a66f-0d03978e7edf
# ╠═461481ef-f88b-4e4e-b57d-ce003abbfdf1
# ╟─6f1707ed-79ab-42dc-8ad8-d66a9e1a65b3
