function makeplots(picdir; Plotter=GLMakie, extension="png")

    p=plotting_multiscene(Plotter=Plotter)

    fname=joinpath(picdir,"plotting_multiscene."*extension)
    save(fname,p,Plotter=Plotter)
    @test isfile(fname)
    println("multiscene")

   
    p=plotting_func3d(Plotter=Plotter)
    fname=joinpath(picdir,"plotting_func3d."*extension)
    save(fname,p,Plotter=Plotter)
    @test isfile(fname)
    println("func3d")


    p=plotting_func2d(Plotter=Plotter)
    fname=joinpath(picdir,"plotting_func2d."*extension)
    save(fname,p,Plotter=Plotter)
    @test isfile(fname)
    println("func2d")

    p=plotting_func1d(Plotter=Plotter)
    fname=joinpath(picdir,"plotting_func1d."*extension)
    save(fname,p,Plotter=Plotter)
    @test isfile(fname)
    println("func1d")

    p=plotting_vec2d(Plotter=Plotter)
    fname=joinpath(picdir,"plotting_vec2d."*extension)
    save(fname,p,Plotter=Plotter)
    @test isfile(fname)
    println("vec2d")

    p=plotting_stream2d(Plotter=Plotter)
    fname=joinpath(picdir,"plotting_stream2d."*extension)
    save(fname,p,Plotter=Plotter)
    @test isfile(fname) || GridVisualize.plottername!="PyPlot"
    println("stream2d")

    p=plotting_grid3d(Plotter=Plotter)
    fname=joinpath(picdir,"plotting_grid3d."*extension)
    save(fname,p,Plotter=Plotter)
    @test isfile(fname)
    println("grid3d")

    p=plotting_grid2d(Plotter=Plotter)
    fname=joinpath(picdir,"plotting_grid2d."*extension)
    save(fname,p,Plotter=Plotter)
    @test isfile(fname)
    println("grid2d")


    p=plotting_grid1d(Plotter=Plotter)
    fname=joinpath(picdir,"plotting_grid1d."*extension)
    save(fname,p,Plotter=Plotter)
    @test isfile(fname)
    println("grid1d")


    true
end
