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
    plotting_func2d(Plotter=PyPlot)
    fname=joinpath(picdir,"plotting_func2d.svg")
    PyPlot.savefig(fname)
    @assert isfile(fname)
    @show "func2d"

    PyPlot.clf()
    plotting_func1d(Plotter=PyPlot)
    fname=joinpath(picdir,"plotting_func1d.svg")
    PyPlot.savefig(fname)
    @assert isfile(fname)
    @show "func1d"

    PyPlot.clf()
    plotting_vec2d(Plotter=PyPlot)
    fname=joinpath(picdir,"plotting_vec2d.svg")
    PyPlot.savefig(fname)
    @assert isfile(fname)
    @show "vec2d"

    PyPlot.clf()
    plotting_stream2d(Plotter=PyPlot)
    fname=joinpath(picdir,"plotting_stream2d.svg")
    PyPlot.savefig(fname)
    @assert isfile(fname)
    @show "stream2d"



    
    PyPlot.clf()
    plotting_grid3d(Plotter=PyPlot)
    fname=joinpath(picdir,"plotting_grid3d.svg")
    PyPlot.savefig(fname)
    @assert isfile(fname)
    @show "grid3d"

    PyPlot.clf()
    plotting_grid2d(Plotter=PyPlot)
    fname=joinpath(picdir,"plotting_grid2d.svg")
    PyPlot.savefig(fname)
    @assert isfile(fname)
    @show "grid2d"


    PyPlot.clf()
    plotting_grid1d(Plotter=PyPlot)
    fname=joinpath(picdir,"plotting_grid1d.svg")
    PyPlot.savefig(fname)
    @assert isfile(fname)
    @show "grid1d"


    true
end
