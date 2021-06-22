### A Pluto.jl notebook ###
# v0.14.8

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
develop=true

# ╔═╡ 9701cbe0-d048-11eb-151b-67dda7b72b71
begin
   using Pkg
   Pkg.activate(mktempdir())
   Pkg.add("Revise")
   using Revise
   Pkg.add(["PyPlot","ExtendableGrids","PlutoUI"])
	if develop
	   Pkg.develop(["PlutoVista","GridVisualize"])
	else
	   Pkg.add(["PlutoVista","GridVisualize"])
	end
   using PyPlot,PlutoVista,GridVisualize,ExtendableGrids,PlutoUI
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
	scalarplot(grid,map(sin,grid),Plotter=Plotter,resolution=(600,300),markershape=:star5,markevery=20, xlabel="x",ylabel="z")
end

# ╔═╡ cc17187f-404c-4c31-8625-fa067eea7273
testplot1(PyPlot)

# ╔═╡ 33482af8-3542-4723-ae43-770a789b69b3
testplot1(PlutoVista)

# ╔═╡ c4eeb06f-932e-4acc-8e5b-f2a7f9242a42
function testplot2(Plotter;t=0)
	p=GridVisualizer(Plotter=Plotter, resolution=(500,300),legend=:rt,xlabel="x")
	grid=simplexgrid(0:0.01:10)	
	scalarplot!(p,grid,map(x->sin(x-t),grid),Plotter=Plotter,color=:red,label="sin",linestyle=:dash)
	scalarplot!(p,grid,map(cos,grid),Plotter=Plotter,color=:green,clear=false,label="cos",linestyle=:dashdot,linewidth=3)
	reveal(p)
end

# ╔═╡ 29ca4775-6ba5-474c-bd2c-8f770b09addd
testplot2(PyPlot)

# ╔═╡ 84192945-d4b6-4949-8f06-d94e04a7a56d
testplot2(PlutoVista)

# ╔═╡ 63fe3259-7d79-40ec-98be-e0592e40ee6b
@bind t2 Slider(0:0.1:5,show_value=true)

# ╔═╡ 4de6b5c9-4d2d-4bcb-bc88-c6f50a23f9b6
testplot2(PlutoVista,t=t2)

# ╔═╡ ae1fe1ab-4a0e-4c80-bd6f-912201fb4bb4
md"""
## 2D Scalar plot
"""

# ╔═╡ d5258595-60e4-406f-a71e-69111cdad8b9
function testplot3(Plotter)
	X=0:0.1:10
	grid=simplexgrid(X,X)
	f=map( (x,y)->sin(x)*atan(y),grid)
	scalarplot(grid,f,Plotter=Plotter,resolution=(300,300),flimits=(-π/2,π/2))
end

# ╔═╡ c98a90bf-1a3e-4681-a3b0-663c6844df6b
testplot3(PyPlot)

# ╔═╡ 0998a9a7-d57a-476e-aacd-bee9396e9b8f
testplot3(PlutoVista)

# ╔═╡ cefb38c1-159e-42db-8088-294573fcece2
md"""
### Changeable data (experimental)
"""

# ╔═╡ a9f4f98f-ec2f-42d6-88da-4a8a6f727e93
begin
	X=0:0.1:10
	grid=simplexgrid(X,X)
	f(t)=map( (x,y)->sin(x-t)*atan(y),grid)
end

# ╔═╡ 412c905f-050c-4b78-a66f-0d03978e7edf
vis=GridVisualizer(resolution=(300,300),Plotter=PlutoVista)

# ╔═╡ 5608a6a1-bba5-4d20-85d6-66151c9ec4b3
scalarplot!(vis[1,1],grid,f(0),resolution=(300,300),flimits=(-π/2,π/2),show=true)

# ╔═╡ 6f1707ed-79ab-42dc-8ad8-d66a9e1a65b3
md"""
t= $(@bind t Slider(-10:0.1:10, default=0, show_value=true))
"""

# ╔═╡ 461481ef-f88b-4e4e-b57d-ce003abbfdf1
scalarplot!(vis[1,1],grid,f(t),resolution=(300,300),flimits=(-π/2,π/2),show=true)

# ╔═╡ Cell order:
# ╠═6df3beed-24a7-4b26-a315-0520f4863190
# ╠═9701cbe0-d048-11eb-151b-67dda7b72b71
# ╠═68e2c958-b417-4ba1-9577-697304fe140a
# ╟─b35d982d-1fa9-413d-b008-892b4f241097
# ╟─00b04f6b-34a6-4e30-9864-d273305281d4
# ╠═a20d74c9-16da-408a-b247-0c17321888f9
# ╠═cc17187f-404c-4c31-8625-fa067eea7273
# ╠═33482af8-3542-4723-ae43-770a789b69b3
# ╠═c4eeb06f-932e-4acc-8e5b-f2a7f9242a42
# ╠═29ca4775-6ba5-474c-bd2c-8f770b09addd
# ╠═84192945-d4b6-4949-8f06-d94e04a7a56d
# ╠═63fe3259-7d79-40ec-98be-e0592e40ee6b
# ╠═4de6b5c9-4d2d-4bcb-bc88-c6f50a23f9b6
# ╟─ae1fe1ab-4a0e-4c80-bd6f-912201fb4bb4
# ╠═d5258595-60e4-406f-a71e-69111cdad8b9
# ╠═c98a90bf-1a3e-4681-a3b0-663c6844df6b
# ╠═0998a9a7-d57a-476e-aacd-bee9396e9b8f
# ╟─cefb38c1-159e-42db-8088-294573fcece2
# ╠═a9f4f98f-ec2f-42d6-88da-4a8a6f727e93
# ╠═412c905f-050c-4b78-a66f-0d03978e7edf
# ╠═5608a6a1-bba5-4d20-85d6-66151c9ec4b3
# ╠═461481ef-f88b-4e4e-b57d-ce003abbfdf1
# ╟─6f1707ed-79ab-42dc-8ad8-d66a9e1a65b3
