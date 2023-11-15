using Test, ExtendableGrids, GridVisualize, Pkg
import CairoMakie
CairoMakie.activate!(; type = "svg", visible = false)

plotting = joinpath(@__DIR__, "..", "examples", "plotting.jl")
include(plotting)
include("../docs/makeplots.jl")
@testset "makeplots - CairoMakie" begin
    makeplots(mktempdir(); Plotter = CairoMakie, extension = ".svg")
end

function testnotebook(input)
    # de-markdown eventual cells with Pkg.develop and write
    # to pluto-tmp.jl
    notebook = Pluto.load_notebook_nobackup(input)
    pkgcellfortest = findfirst(c -> occursin("Pkg.develop", c.code), notebook.cells)
    if pkgcellfortest != nothing
        # de-markdown pkg cell
        notebook.cells[pkgcellfortest].code = replace(notebook.cells[pkgcellfortest].code, "md" => "")
        notebook.cells[pkgcellfortest].code = replace(notebook.cells[pkgcellfortest].code, "\"\"\"" => "")
        notebook.cells[pkgcellfortest].code = replace(notebook.cells[pkgcellfortest].code, ";" => "")
        @info "Pkg cell: $(pkgcellfortest)\n$(notebook.cells[pkgcellfortest].code)"
        Pluto.save_notebook(notebook, "pluto-tmp.jl")
        input = "pluto-tmp.jl"
        eval(Meta.parse(notebook.cells[pkgcellfortest].code))
    end

    # run notebook and check for cell errors
    session = Pluto.ServerSession()
    notebook = Pluto.SessionActions.open(session, input; run_async = false)
    errored = false
    for c in notebook.cells
        if c.errored
            errored = true
            @error "Error in  $(c.cell_id): $(c.output.body[:msg])\n $(c.code)"
        end
    end
    !errored
end

@testset "notebooks" begin
    # notebooks=["plutovista.jl"]
    # for notebook in notebooks
    #     input=joinpath(@__DIR__,"..","examples",notebook)
    #     @info "notebook: $(input)"
    #     @test testnotebook(input)
    # end
end
