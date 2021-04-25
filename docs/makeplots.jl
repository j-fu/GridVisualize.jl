function makeplots(picdir)
    PyPlot.clf()
    plotting_multiscene(Plotter=PyPlot)
    fname=joinpath(picdir,"plotting_multiscene.svg")
    PyPlot.savefig(fname)
    @assert isfile(fname)
    @show "multiscene"

   
    PyPlot.clf()
    plotting_func3d(Plotter=PyPlot)
    fname=joinpath(picdir,"plotting_func3d.svg")
    PyPlot.savefig(fname)
    @assert isfile(fname)
    @show "func3d"

    PyPlot.clf()
    plotting_grid3d(Plotter=PyPlot)
    fname=joinpath(picdir,"plotting_grid3d.svg")
    PyPlot.savefig(fname)
    @assert isfile(fname)
    @show "grid3d"
    true
end
