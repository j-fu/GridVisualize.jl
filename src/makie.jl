using Observables

include("flippablelayout.jl")

function initialize!(p::GridVisualizer, ::Type{MakieType})
    XMakie = p.context[:Plotter]

    # Check for version compatibility
    version_min = v"0.19"
    version_max = v"0.19.99"

    version_installed = PkgVersion.Version(XMakie.Makie)

    if version_installed < version_min
        error("Outdated version $(version_installed) of XMakie. Please upgrade to at least $(version_min)")
    end

    if version_installed > version_max
        @warn("Possibly breaking version $(version_installed) of XMakie.")
    end

    # Prepare flippable layout
    FlippableLayout.setmakie!(XMakie.Makie)

    layout = p.context[:layout]

    parent, flayout = FlippableLayout.flayoutscene(; resolution = p.context[:size])

    p.context[:figure] = parent
    p.context[:flayout] = flayout

    # copy arguments to sublayout
    for I in CartesianIndices(layout)
        ctx = p.subplots[I]
        ctx[:figure] = parent
        ctx[:flayout] = flayout
    end

    # Don't call display on pluto
    if !isdefined(Main, :PlutoRunner)
        XMakie.display(parent)
    end

    parent
end

# Adding a scene to the layout just adds to the
# flippable layout.
add_scene!(ctx, ax) = ctx[:flayout][ctx[:subplot]...] = ax

# Revealing the  visualizer just returns the figure
reveal(p::GridVisualizer, ::Type{MakieType}) = p.context[:figure]

function reveal(ctx::SubVisualizer, TP::Type{MakieType})
    FlippableLayout.yieldwait(ctx[:flayout])
    if ctx[:show] || ctx[:reveal]
        reveal(ctx[:GridVisualizer], TP)
    end
end

function save(fname, p::GridVisualizer, ::Type{MakieType})
    p.context[:Plotter].save(fname, p.context[:figure])
end
function save(fname, scene, XMakie, ::Type{MakieType})
    isnothing(scene) ? nothing : XMakie.save(fname, scene)
end

"""

     scene_interaction(update_scene,view,switchkeys::Vector{Symbol}=[:nothing])   

Control multiple scene elements via keyboard up/down keys. 
Each switchkey is assumed to correspond to one of these elements.
Pressing a switch key transfers control to its associated element.

Control of values of the current associated element is performed
by triggering change values via up/down (± 1)  resp. page_up/page_down (±10) keys

The update_scene callback gets passed the change value and the symbol.
"""
function scene_interaction(update_scene, scene, XMakie,
                           switchkeys::Vector{Symbol} = [:nothing])

    # Check if pixel position pos sits within the scene
    function _inscene(scene, pos)
        area = scene.px_area[]
        pos[1] > area.origin[1] &&
            pos[1] < area.origin[1] + area.widths[1] &&
            pos[2] > area.origin[2] &&
            pos[2] < area.origin[2] + area.widths[2]
    end

    # Initial active switch key is the first in the vector passed
    activeswitch = Observable(switchkeys[1])

    # Handle mouse position within scene
    mouseposition = Observable((0.0, 0.0))

    XMakie.on(scene.events.mouseposition) do m
        mouseposition[] = m
        false
    end

    # Set keyboard event callback
    XMakie.on(scene.events.keyboardbutton) do buttons
        if _inscene(scene, mouseposition[])
            # On pressing a switch key, pass control
            for i = 1:length(switchkeys)
                if switchkeys[i] != :nothing &&
                   XMakie.ispressed(scene, getproperty(XMakie.Keyboard, switchkeys[i]))
                    activeswitch[] = switchkeys[i]
                    update_scene(0, switchkeys[i])
                    return true
                end
            end

            # Handle change values via up/down control
            if XMakie.ispressed(scene, XMakie.Keyboard.up)
                update_scene(1, activeswitch[])
                return true
            elseif XMakie.ispressed(scene, XMakie.Keyboard.down)
                update_scene(-1, activeswitch[])
                return true
            elseif XMakie.ispressed(scene, XMakie.Keyboard.page_up)
                update_scene(10, activeswitch[])
                return true
            elseif XMakie.ispressed(scene, XMakie.Keyboard.page_down)
                update_scene(-10, activeswitch[])
                return true
            end
        end
        return false
    end
end

# Standard kwargs for Makie scenes
scenekwargs(ctx) = Dict(
                        #:xticklabelsize => 0.5*ctx[:fontsize],
                        #:yticklabelsize => 0.5*ctx[:fontsize],
                        #:zticklabelsize => 0.5*ctx[:fontsize],
                        #:xlabelsize => 0.5*ctx[:fontsize],
                        #:ylabelsize => 0.5*ctx[:fontsize],
                        #:zlabelsize => 0.5*ctx[:fontsize],
                        #:xlabeloffset => 20,
                        #:ylabeloffset => 20,
                        #:zlabeloffset => 20,
                        :titlesize => ctx[:fontsize])

#scenekwargs(ctx)=()

############################################################################################################
#1D grid

# Point list for node markers
function basemesh1d(grid)
    coord = vec(grid[Coordinates])
    ncoord = length(coord)
    points = Vector{Point2f}(undef, 0)
    (xmin, xmax) = extrema(coord)
    h = (xmax - xmin) / 40.0
    for i = 1:ncoord
        push!(points, Point2f(coord[i], h))
        push!(points, Point2f(coord[i], -h))
    end
    points
end

# Point list for intervals
function regionmesh1d(grid, iregion)
    coord = vec(grid[Coordinates])
    points = Vector{Point2f}(undef, 0)
    cn = grid[CellNodes]
    cr = grid[CellRegions]
    ncells = length(cr)
    for i = 1:ncells
        if cr[i] == iregion
            push!(points, Point2f(coord[cn[1, i]], 0))
            push!(points, Point2f(coord[cn[2, i]], 0))
        end
    end
    points
end

# Point list for boundary nodes
function bregionmesh1d(grid, ibreg)
    nbfaces = num_bfaces(grid)
    bfacenodes = grid[BFaceNodes]
    bfaceregions = grid[BFaceRegions]
    coord = vec(grid[Coordinates])
    points = Vector{Point2f}(undef, 0)
    (xmin, xmax) = extrema(coord)
    h = (xmax - xmin) / 20.0
    for ibface = 1:nbfaces
        if bfaceregions[ibface] == ibreg
            push!(points, Point2f(coord[bfacenodes[1, ibface]], h))
            push!(points, Point2f(coord[bfacenodes[1, ibface]], -h))
        end
    end
    points
end

# Point list for scene size
function scenecorners1d(grid)
    coord = vec(grid[Coordinates])
    (xmin, xmax) = extrema(coord)
    h = (xmax - xmin) / 40.0
    [Point2f(xmin, -5 * h), Point2f(xmax, 5 * h)]
end

function gridplot!(ctx, TP::Type{MakieType}, ::Type{Val{1}}, grid)
    XMakie = ctx[:Plotter]
    nregions = num_cellregions(grid)
    nbregions = num_bfaceregions(grid)

    if !haskey(ctx, :scene)
        ctx[:scene] = XMakie.Axis(ctx[:figure];
                                  yticklabelsvisible = false,
                                  yticksvisible = false,
                                  title = ctx[:title],
                                  scenekwargs(ctx)...)

        ctx[:grid] = Observable(grid)
        cmap = region_cmap(nregions)
        bcmap = bregion_cmap(nbregions)

        # Set scene size with invisible markers
        XMakie.scatter!(ctx[:scene],
                        map(g -> scenecorners1d(grid), ctx[:grid]);
                        color = :white,
                        markersize = 0.0,
                        strokewidth = 0)

        # Draw node markers
        XMakie.linesegments!(ctx[:scene],
                             map(g -> basemesh1d(g), ctx[:grid]);
                             color = :black)

        # Colored cell regions
        for i = 1:nregions
            XMakie.linesegments!(ctx[:scene],
                                 map(g -> regionmesh1d(g, i), ctx[:grid]);
                                 color = cmap[i],
                                 linewidth = 4,
                                 label = "c $(i)")
        end

        # Colored boundary grid
        for i = 1:nbregions
            XMakie.linesegments!(ctx[:scene],
                                 map(g -> bregionmesh1d(g, i), ctx[:grid]);
                                 color = bcmap[i],
                                 linewidth = 4,
                                 label = "b$(i)")
        end

        # Legende
        if ctx[:legend] != :none
            pos = ctx[:legend] == :best ? :rt : ctx[:legend]
            XMakie.axislegend(ctx[:scene];
                              position = pos,
                              labelsize = 0.5 * ctx[:fontsize],
                              nbanks = 5)
        end
        XMakie.reset_limits!(ctx[:scene])
        add_scene!(ctx, ctx[:scene])
    else
        ctx[:grid][] = grid
    end
    reveal(ctx, TP)
end

########################################################################
# 1D function

function scalarplot!(ctx, TP::Type{MakieType}, ::Type{Val{1}}, grid, func)
    XMakie = ctx[:Plotter]

    if ctx[:title] == ""
        ctx[:title] = " "
    end

    # ... keep this for the case we are unsorted
    function polysegs(grid, func)
        points = Vector{Point2f}(undef, 0)
        cellnodes = grid[CellNodes]
        coord = grid[Coordinates]
        for icell = 1:num_cells(grid)
            i1 = cellnodes[1, icell]
            i2 = cellnodes[2, icell]
            x1 = coord[1, i1]
            x2 = coord[1, i2]
            push!(points, Point2f(x1, func[i1]))
            push!(points, Point2f(x2, func[i2]))
        end
        points
    end

    function polyline(grid, func)
        coord = grid[Coordinates]
        points = [Point2f(coord[1, i], func[i]) for i = 1:length(func)]
    end

    coord = grid[Coordinates]
    xlimits = ctx[:xlimits]
    ylimits = ctx[:limits]
    xmin = coord[1, 1]
    xmax = coord[1, end]
    if xlimits[1] < xlimits[2]
        xmin = xlimits[1]
        xmax = xlimits[2]
    end

    (ymin, ymax) = extrema(func)
    if ylimits[1] < ylimits[2]
        ymin = ylimits[1]
        ymax = ylimits[2]
    end

    function update_lines(ctx)
        if ctx[:markershape] == :none
            #line without marker
            XMakie.lines!(ctx[:scene], map(a -> a, ctx[:lines][end]);
                          linestyle = ctx[:linestyle],
                          linewidth = ctx[:linewidth],
                          color = RGB(ctx[:color]),
                          label = ctx[:label])
        else
            # line with markers separated by markevery

            # draw plain line without the label
            XMakie.lines!(ctx[:scene], map(a -> a, ctx[:lines][end]);
                          linestyle = ctx[:linestyle],
                          color = RGB(ctx[:color]),
                          linewidth = ctx[:linewidth])

            # draw markers without label
            XMakie.scatter!(ctx[:scene],
                            map(a -> a[1:ctx[:markevery]:end], ctx[:lines][end]);
                            color = RGB(ctx[:color]),
                            marker = ctx[:markershape],
                            markercolor = RGB(ctx[:color]),
                            markersize = ctx[:markersize])

            # Draw  dummy line with marker on top ot the first
            # marker position already drawn in order to
            # get the proper legend entry
            if ctx[:label] != ""
                XMakie.scatterlines!(ctx[:scene],
                                     map(a -> a[1:1], ctx[:lines][end]);
                                     linestyle = ctx[:linestyle],
                                     linewidth = ctx[:linewidth],
                                     marker = ctx[:markershape],
                                     markersize = ctx[:markersize],
                                     markercolor = RGB(ctx[:color]),
                                     color = RGB(ctx[:color]),
                                     label = ctx[:label])
            end
        end

        if ctx[:legend] != :none
            pos = ctx[:legend] == :best ? :rt : ctx[:legend]
            XMakie.axislegend(ctx[:scene]; position = pos, labelsize = 0.5 * ctx[:fontsize])
            # ,backgroundcolor=:transparent
        end
    end

    if !haskey(ctx, :scene)
        ctx[:xtitle] = Observable(ctx[:title])

        # Axis
        ctx[:scene] = XMakie.Axis(ctx[:figure];
                                  title = map(a -> a, ctx[:xtitle]),
                                  xscale = ctx[:xscale] == :log ? log10 : identity,
                                  yscale = ctx[:yscale] == :log ? log10 : identity,
                                  scenekwargs(ctx)...)
        # Plot size
        XMakie.scatter!(ctx[:scene],
                        [Point2f(xmin, ymin), Point2f(xmax, ymax)];
                        color = :white,
                        markersize = 0.0,
                        strokewidth = 0)

        # ctx[:lines]  is an array of lines to draw
        # Here, we start just with the first one.
        ctx[:lines] = [Observable(polyline(grid, func))]

        update_lines(ctx)

        XMakie.reset_limits!(ctx[:scene])

        ctx[:nlines] = 1

        XMakie.reset_limits!(ctx[:scene])
        add_scene!(ctx, ctx[:scene])

    else
        if ctx[:clear]
            ctx[:nlines] = 1
        else
            ctx[:nlines] += 1
        end

        p = polyline(grid, func)
        # Either update existing line, or
        # create new one. This works with repeating sequences of
        # updating lines.
        if ctx[:nlines] <= length(ctx[:lines])
            ctx[:lines][ctx[:nlines]][] = p
        else
            push!(ctx[:lines], Observable(p))
            update_lines(ctx)
        end

        XMakie.reset_limits!(ctx[:scene])

        ctx[:xtitle][] = ctx[:title]
    end
    reveal(ctx, TP)
end

#######################################################################################
# 2D grid

function makescene_grid(ctx)
    XMakie = ctx[:Plotter]
    GL = XMakie.GridLayout(ctx[:figure])
    GL[1, 1] = ctx[:scene]
    ncol = length(ctx[:cmap])
    nbcol = length(ctx[:cmap])
    # fontsize=0.5*ctx[:fontsize],ticklabelsize=0.5*ctx[:fontsize]
    if ctx[:colorbar] == :vertical
        GL[1, 2] = XMakie.Colorbar(ctx[:figure];
                                   colormap = XMakie.cgrad(ctx[:cmap]; categorical = true),
                                   limits = (1, ncol),
                                   width = 15)
        GL[1, 3] = XMakie.Colorbar(ctx[:figure];
                                   colormap = XMakie.cgrad(ctx[:bcmap]; categorical = true),
                                   limits = (1, nbcol),
                                   width = 15)
    elseif ctx[:colorbar] == :horizontal
        GL[2, 1] = XMakie.Colorbar(ctx[:figure];
                                   colormap = XMakie.cgrad(ctx[:cmap]; categorical = true),
                                   limits = (1, ncol),
                                   heigth = 15,
                                   vertical = false)
        GL[3, 1] = XMakie.Colorbar(ctx[:figure];
                                   colormap = XMakie.cgrad(ctx[:bcmap]; categorical = true),
                                   limits = (1, nbcol),
                                   heigth = 15,
                                   vertical = false)
    end
    GL
end

# Put all data which could be updated in to one plot.
function set_plot_data!(ctx, key, data)
    haskey(ctx, key) ? ctx[key][] = data : ctx[key] = Observable(data)
end

function gridplot!(ctx, TP::Type{MakieType}, ::Type{Val{2}}, grid)
    XMakie = ctx[:Plotter]

    nregions = num_cellregions(grid)

    nbregions = num_bfaceregions(grid)

    set_plot_data!(ctx, :grid, grid)

    if !haskey(ctx, :gridplot)
        if !haskey(ctx, :scene)
            coord = grid[Coordinates]
            ex = extrema(coord; dims = (2))
            data_aspect = (ex[2][2] - ex[2][1]) / (ex[1][2] - ex[1][1])
            makie_aspect = 1.0 / (data_aspect * ctx[:aspect])
            ctx[:scene] = XMakie.Axis(ctx[:figure];
                                      title = ctx[:title],
                                      aspect = makie_aspect,
                                      scenekwargs(ctx)...)
        end

        # Draw cells with region mark
        cmap = region_cmap(nregions)
        ctx[:cmap] = cmap
        for i = 1:nregions
            XMakie.poly!(ctx[:scene], map(g -> regionmesh(g, i), ctx[:grid]);
                         color = cmap[i],
                         strokecolor = :black,
                         strokewidth = ctx[:linewidth])
        end

        # Draw boundary lines
        bcmap = bregion_cmap(nbregions)
        ctx[:bcmap] = bcmap
        for i = 1:nbregions
            lp = XMakie.linesegments!(ctx[:scene],
                                      map(g -> bfacesegments(g, i), ctx[:grid]);
                                      label = "$(i)",
                                      color = bcmap[i],
                                      linewidth = 4)
            XMakie.translate!(lp, 0, 0, 0.1)
        end
        XMakie.reset_limits!(ctx[:scene])

        # Describe legend
        if ctx[:legend] != :none
            pos = ctx[:legend] == :best ? :rt : ctx[:legend]
            XMakie.axislegend(ctx[:scene];
                              position = pos,
                              labelsize = 0.5 * ctx[:fontsize],
                              backgroundcolor = :transparent)
        end
        add_scene!(ctx, makescene_grid(ctx))
    end
    reveal(ctx, TP)
end

"""
   makescene2d(ctx)

Complete scene with title and status line showing interaction state.
This uses a gridlayout and its  protrusion capabilities.
"""
function makescene2d(ctx, key)
    XMakie = ctx[:Plotter]
    GL = XMakie.GridLayout(ctx[:figure])
    GL[1, 1] = ctx[:scene]

    # , fontsize=0.5*ctx[:fontsize],ticklabelsize=0.5*ctx[:fontsize]
    if ctx[:colorbar] == :vertical
        GL[1, 2] = XMakie.Colorbar(ctx[:figure], ctx[key]; width = 10,
                                   ticks = unique(ctx[:cbarticks]))
    elseif ctx[:colorbar] == :horizontal
        GL[2, 1] = XMakie.Colorbar(ctx[:figure], ctx[key]; height = 10,
                                   ticks = ctx[:cbarticks], vertical = false)
    end
    GL
end

# 2D function
function scalarplot!(ctx, TP::Type{MakieType}, ::Type{Val{2}}, grid, func)
    XMakie = ctx[:Plotter]

    # Create GeometryBasics.mesh from grid data.
    function make_mesh(grid::ExtendableGrid, func, elevation)
        coord = grid[Coordinates]
        npoints = num_nodes(grid)
        cellnodes = grid[CellNodes]
        if elevation ≈ 0.0
            points = [Point2f(coord[1, i], coord[2, i]) for i = 1:npoints]
        else
            points = [Point3f(coord[1, i], coord[2, i], func[i] * elevation)
                      for i = 1:npoints]
        end
        faces = [TriangleFace(cellnodes[1, i], cellnodes[2, i], cellnodes[3, i])
                 for i = 1:size(cellnodes, 2)]
        Mesh(points, faces)
    end

    levels, crange, ctx[:cbarticks] = isolevels(ctx, func)
    eps = 1.0e-1
    if crange[1] == crange[2]
        crange = (crange[1] - eps, crange[1] + eps)
    end

    set_plot_data!(ctx, :contourdata,
                   (g = grid, f = func, e = ctx[:elevation], t = ctx[:title], l = levels,
                    c = crange))

    if !haskey(ctx, :contourplot)
        if !haskey(ctx, :scene)
            coord = grid[Coordinates]
            ex = extrema(coord; dims = (2))
            data_aspect = (ex[2][2] - ex[2][1]) / (ex[1][2] - ex[1][1])
            makie_aspect = 1.0 / (data_aspect * ctx[:aspect])
            # would need to switch to Axis3 for supporting elevation
            ctx[:scene] = XMakie.Axis(ctx[:figure];
                                      title = map(data -> data.t, ctx[:contourdata]),
                                      aspect = makie_aspect,
                                      scenekwargs(ctx)...)
        end

        # Draw the mesh for the cells
        ctx[:contourplot] = XMakie.poly!(ctx[:scene],
                                         map(data -> make_mesh(data.g, data.f, data.e),
                                             ctx[:contourdata]);
                                         color = map(data -> data.f, ctx[:contourdata]),
                                         colorrange = map(data -> data.c,
                                                          ctx[:contourdata]),
                                         colormap = ctx[:colormap])

        # draw the isolines via marching triangles
        XMakie.linesegments!(ctx[:scene],
                             map(data -> marching_triangles(data.g, data.f, data.l),
                                 ctx[:contourdata]);
                             color = :black,
                             linewidth = ctx[:linewidth])

        XMakie.reset_limits!(ctx[:scene])
        add_scene!(ctx, makescene2d(ctx, :contourplot))
    end
    reveal(ctx, TP)
end

# 2D vector
function vectorplot!(ctx, TP::Type{MakieType}, ::Type{Val{2}}, grid, func)
    XMakie = ctx[:Plotter]

    rc, rv = vectorsample(grid, func; spacing = ctx[:spacing], offset = ctx[:offset])
    qc, qv = quiverdata(rc, rv; vscale = ctx[:vscale], vnormalize = ctx[:vnormalize])

    set_plot_data!(ctx, :arrowdata, (qc = qc, qv = qv))

    if !haskey(ctx, :arrowplot)
        if !haskey(ctx, :scene)
            ctx[:scene] = XMakie.Axis(ctx[:figure];
                                      title = ctx[:title],
                                      aspect = XMakie.DataAspect(),
                                      scenekwargs(ctx)...)
            add_scene!(ctx, ctx[:scene])
        end

        ctx[:arrowplot] = XMakie.arrows!(ctx[:scene],
                                         map(data -> data.qc[1, :], ctx[:arrowdata]),
                                         map(data -> data.qc[2, :], ctx[:arrowdata]),
                                         map(data -> data.qv[1, :], ctx[:arrowdata]),
                                         map(data -> data.qv[2, :], ctx[:arrowdata]);
                                         color = :black,
                                         linewidth = ctx[:linewidth])
        XMakie.reset_limits!(ctx[:scene])
    end
    reveal(ctx, TP)
end

function streamplot!(ctx, TP::Type{MakieType}, ::Type{Val{2}}, grid, func) end

#######################################################################################
#######################################################################################
# 3D Grid

function xyzminmax(grid::ExtendableGrid)
    coord = grid[Coordinates]
    ndim = size(coord, 1)
    xyzmin = zeros(ndim)
    xyzmax = ones(ndim)
    for idim = 1:ndim
        @views mn, mx = extrema(coord[idim, :])
        xyzmin[idim] = mn
        xyzmax[idim] = mx
    end
    xyzmin, xyzmax
end

"""
   makeaxis3d(ctx)

Dispatch between LScene and new Axis3. Axis3 does not allow zoom, so we
support LScene in addition.
"""
function makeaxis3d(ctx)
    XMakie = ctx[:Plotter]
    if ctx[:scene3d] == :LScene
        # "Old" LScene with zoom-in functionality
        XMakie.LScene(ctx[:figure])
    else
        # "New" Axis3 with prospective new stuff by Julius.
        XMakie.Axis3(ctx[:figure];
                     aspect = :data,
                     viewmode = :fit,
                     elevation = ctx[:elev] * π / 180,
                     azimuth = ctx[:azim] * π / 180,
                     perspectiveness = ctx[:perspectiveness],
                     title = map(data -> data.t, ctx[:data]),
                     scenekwargs(ctx)...)
    end
end

"""
       makescene3d(ctx)

Complete scene with title and status line showing interaction state.
This uses a gridlayout and its  protrusion capabilities.
"""
function makescene3d(ctx)
    XMakie = ctx[:Plotter]
    GL = XMakie.GridLayout(ctx[:figure]; default_rowgap = 0)
    if ctx[:scene3d] == "LScene"
        # LScene has no title, put the title into protrusion space on top  of the scene
        GL[1, 1, XMakie.Top()] = XMakie.Label(ctx[:figure],
                                              " $(map(data->data.t,ctx[:data])) ";
                                              tellwidth = false,
                                              height = 30,
                                              fontsize = ctx[:fontsize])
    end
    GL[1, 1] = ctx[:scene]
    # Horizontal or vertical colorbar
    if haskey(ctx, :crange)
        if ctx[:colorbar] == :vertical
            GL[1, 2] = XMakie.Colorbar(ctx[:figure];
                                       colormap = ctx[:colormap],
                                       colorrange = ctx[:crange],
                                       ticks = ctx[:levels],
                                       width = 15,
                                       ticklabelsize = 0.5 * ctx[:fontsize])
        elseif ctx[:colorbar] == :horizontal
            GL[2, 1] = XMakie.Colorbar(ctx[:figure];
                                       colormap = ctx[:colormap],
                                       colorrange = ctx[:crange],
                                       ticks = ctx[:levels],
                                       height = 15,
                                       ticklabelsize = 0.5 * ctx[:fontsize],
                                       vertical = false)
        end
    end

    # Put the status label into protrusion space on the bottom of the scene
    GL[1, 1, XMakie.Bottom()] = XMakie.Label(ctx[:figure],
                                             ctx[:status];
                                             tellwidth = false,
                                             height = 30,
                                             fontsize = 0.5 * ctx[:fontsize])
    GL
end

const keyboardhelp = """
                         Keyboard interactions:
                               x: control xplane
                               y: control yplane
                               z: control zplane
                               l: control isolevel
                         up/down: fine control control value
                     pgup/pgdown: coarse control control value
                               h: print this message
                     """

function gridplot!(ctx, TP::Type{MakieType}, ::Type{Val{3}}, grid)
    make_mesh(pts, fcs) = Mesh(meta(pts; normals = normals(pts, fcs)), fcs)

    nregions = num_cellregions(grid)
    nbregions = num_bfaceregions(grid)

    XMakie = ctx[:Plotter]
    xyzmin, xyzmax = xyzminmax(grid)
    xyzstep = (xyzmax - xyzmin) / 100

    function adjust_planes()
        ctx[:xplanes][1] = max(xyzmin[1], min(xyzmax[1], ctx[:xplanes][1]))
        ctx[:yplanes][1] = max(xyzmin[2], min(xyzmax[2], ctx[:yplanes][1]))
        ctx[:zplanes][1] = max(xyzmin[3], min(xyzmax[3], ctx[:zplanes][1]))
    end

    adjust_planes()

    if !haskey(ctx, :scene)
        ctx[:data] = Observable((g = grid, x = ctx[:xplanes][1], y = ctx[:yplanes][1],
                                 z = ctx[:zplanes][1], t = ctx[:title]))

        ctx[:scene] = makeaxis3d(ctx)
        cmap = region_cmap(nregions)
        ctx[:cmap] = cmap
        bcmap = bregion_cmap(nbregions)
        ctx[:bcmap] = bcmap

        ############# Interior cuts
        # We draw a mesh for each color.
        if ctx[:interior]
            ctx[:celldata] = map(d -> extract_visible_cells3D(d.g,
                                                              (d.x, d.y, d.z);
                                                              primepoints = hcat(xyzmin,
                                                                                 xyzmax),
                                                              Tp = Point3f,
                                                              Tf = GLTriangleFace),
                                 ctx[:data])

            ctx[:cellmeshes] = map(d -> [make_mesh(d[1][i], d[2][i]) for i = 1:nregions],
                                   ctx[:celldata])

            for i = 1:nregions
                XMakie.mesh!(ctx[:scene], map(d -> d[i], ctx[:cellmeshes]);
                             color = cmap[i],
                             backlight = 1.0f0)

                if ctx[:linewidth] > 0
                    XMakie.wireframe!(ctx[:scene], map(d -> d[i], ctx[:cellmeshes]);
                                      color = :black,
                                      strokecolor = :black,
                                      strokewidth = ctx[:linewidth],
                                      linewidth = ctx[:linewidth])
                end
            end
        end

        ############# Visible boundary faces
        ctx[:facedata] = map(d -> extract_visible_bfaces3D(d.g,
                                                           (d.x, d.y, d.z);
                                                           primepoints = hcat(xyzmin,
                                                                              xyzmax),
                                                           Tp = Point3f,
                                                           Tf = GLTriangleFace),
                             ctx[:data])

        ctx[:facemeshes] = map(d -> [make_mesh(d[1][i], d[2][i]) for i = 1:nbregions],
                               ctx[:facedata])

        for i = 1:nbregions
            XMakie.mesh!(ctx[:scene], map(d -> d[i], ctx[:facemeshes]);
                         color = bcmap[i],
                         backlight = 1.0f0)
            if ctx[:linewidth] > 0
                XMakie.wireframe!(ctx[:scene], map(d -> d[i], ctx[:facemeshes]);
                                  color = :black,
                                  strokecolor = :black,
                                  linewidth = ctx[:linewidth])
            end
        end

        ############# Transparent outline

        if ctx[:outlinealpha] > 0.0
            ctx[:outlinedata] = map(d -> extract_visible_bfaces3D(d.g,
                                                                  xyzmax;
                                                                  primepoints = hcat(xyzmin,
                                                                                     xyzmax),
                                                                  Tp = Point3f,
                                                                  Tf = GLTriangleFace),
                                    ctx[:data])
            ctx[:outlinemeshes] = map(d -> [make_mesh(d[1][i], d[2][i]) for i = 1:nbregions],
                                      ctx[:outlinedata])

            for i = 1:nbregions
                XMakie.mesh!(ctx[:scene], map(d -> d[i], ctx[:outlinemeshes]);
                             color = (bcmap[i], ctx[:outlinealpha]),
                             transparency = true,
                             backlight = 1.0f0)
            end
        end

        ##### Interaction
        scene_interaction(ctx[:scene].scene, XMakie, [:z, :y, :x, :q]) do delta, key
            if key == :x
                ctx[:xplanes][1] += delta * xyzstep[1]
                ctx[:status][] = @sprintf("x=%.3g", ctx[:xplanes][1])
            elseif key == :y
                ctx[:yplanes][1] += delta * xyzstep[2]
                ctx[:status][] = @sprintf("y=%.3g", ctx[:yplanes][1])
            elseif key == :z
                ctx[:zplanes][1] += delta * xyzstep[3]
                ctx[:status][] = @sprintf("z=%.3g", ctx[:zplanes][1])
            elseif key == :q
                ctx[:status][] = " "
            end
            adjust_planes()

            ctx[:data][] = (g = grid, x = ctx[:xplanes][1], y = ctx[:yplanes][1],
                            z = ctx[:zplanes][1], t = ctx[:title])
        end

        ctx[:status] = Observable(" ")

        add_scene!(ctx, makescene_grid(ctx))

    else
        ctx[:data][] = (g = grid, x = ctx[:xplanes][1], y = ctx[:yplanes][1],
                        z = ctx[:zplanes][1], t = ctx[:title])
    end

    reveal(ctx, TP)
end

# 3d function
function scalarplot!(ctx, TP::Type{MakieType}, ::Type{Val{3}}, grid, func)
    levels, crange = isolevels(ctx, func)
    ctx[:crange] = crange

    nan_replacement = 0.5 * (crange[1] + crange[2])
    make_mesh(pts, fcs) = Mesh(pts, fcs)

    function make_mesh(pts, fcs, vals)
        if length(fcs) > 0
            colors = XMakie.Makie.interpolated_getindex.((cmap,), vals, (crange,))
            if ctx[:levelalpha] > 0
                colors = [RGBA(colors[i].r, colors[i].g, colors[i].b,
                               Float32(ctx[:levelalpha])) for i = 1:length(colors)]
            end
            GeometryBasics.Mesh(meta(pts; color = colors, normals = normals(pts, fcs)), fcs)
        else
            GeometryBasics.Mesh(pts, fcs)
        end
    end

    nregions = num_cellregions(grid)
    nbregions = num_bfaceregions(grid)

    XMakie = ctx[:Plotter]
    cmap = XMakie.to_colormap(ctx[:colormap])
    xyzmin, xyzmax = xyzminmax(grid)
    xyzstep = (xyzmax - xyzmin) / 100

    fstep = (crange[2] - crange[1]) / 100
    if fstep ≈ 0
        fstep = 0.1
    end

    # function adjust_planes()
    #     ctx[:xplanes][1]=max(xyzmin[1],min(xyzmax[1],ctx[:xplanes][1]) )
    #     ctx[:yplanes][1]=max(xyzmin[2],min(xyzmax[2],ctx[:yplanes][1]) )
    #     ctx[:zplanes][1]=max(xyzmin[3],min(xyzmax[3],ctx[:zplanes][1]) )
    #     ctx[:flevel]=max(fminmax[1],min(fminmax[2],ctx[:flevel]))
    # end

    # adjust_planes()

    x = ctx[:xplanes]
    y = ctx[:yplanes]
    z = ctx[:zplanes]

    ε = 1.0e-5 * (xyzmax .- xyzmin)

    ctx[:xplanes] = isa(x, Number) ?
                    collect(range(xyzmin[1] + ε[1], xyzmax[1] - ε[1]; length = ceil(x))) : x
    ctx[:yplanes] = isa(y, Number) ?
                    collect(range(xyzmin[2] + ε[2], xyzmax[2] - ε[2]; length = ceil(y))) : y
    ctx[:zplanes] = isa(z, Number) ?
                    collect(range(xyzmin[3] + ε[3], xyzmax[3] - ε[3]; length = ceil(z))) : z

    ctx[:xplanes][1] = min(xyzmax[1], ctx[:xplanes][1])
    ctx[:yplanes][1] = min(xyzmax[2], ctx[:yplanes][1])
    ctx[:zplanes][1] = min(xyzmax[3], ctx[:zplanes][1])

    ctx[:levels] = levels

    if !haskey(ctx, :scene)
        ctx[:data] = Observable((g = grid, f = func, x = ctx[:xplanes], y = ctx[:yplanes],
                                 z = ctx[:zplanes], l = ctx[:levels], t = ctx[:title]))

        ctx[:scene] = makeaxis3d(ctx)

        #### Transparent outlne
        if ctx[:outlinealpha] > 0.0
            ctx[:outlinedata] = map(d -> extract_visible_bfaces3D(d.g,
                                                                  xyzmax;
                                                                  primepoints = hcat(xyzmin,
                                                                                     xyzmax),
                                                                  Tp = Point3f,
                                                                  Tf = GLTriangleFace),
                                    ctx[:data])
            ctx[:facemeshes] = map(d -> [make_mesh(d[1][i], d[2][i]) for i = 1:nbregions],
                                   ctx[:outlinedata])
            bcmap = bregion_cmap(nbregions)
            for i = 1:nbregions
                XMakie.mesh!(ctx[:scene], map(d -> d[i], ctx[:facemeshes]);
                             color = (bcmap[i], ctx[:outlinealpha]),
                             transparency = true,
                             backlight = 1.0f0)
            end
        end

        f = d -> make_mesh(marching_tetrahedra(d.g,
                                               d.f,
                                               makeplanes(xyzmin, xyzmax, d.x, d.y, d.z),
                                               d.l;
                                               primepoints = hcat(xyzmin, xyzmax),
                                               primevalues = crange,
                                               tol = ctx[:tetxplane_tol],
                                               Tp = Point3f,
                                               Tf = GLTriangleFace,
                                               Tv = Float32)...)

        #### Plane sections and isosurfaces
        ctx[:mesh] = XMakie.mesh!(ctx[:scene], map(f, ctx[:data]); backlight = 1.0f0,
                                  transparency = ctx[:levelalpha] < 1.0)
        #### Interactions
        scene_interaction(ctx[:scene].scene, XMakie, [:z, :y, :x, :l, :q]) do delta, key
            if key == :x
                ctx[:xplanes] .+= delta * xyzstep[1]
                ctx[:status][] = "x=[" *
                                 mapreduce(x -> @sprintf("%.3g,", x), *, ctx[:xplanes]) *
                                 "]"
            elseif key == :y
                ctx[:yplanes] .+= delta * xyzstep[2]
                ctx[:status][] = "y=[" *
                                 mapreduce(y -> @sprintf("%.3g,", y), *, ctx[:yplanes]) *
                                 "]"
            elseif key == :z
                ctx[:zplanes] .+= delta * xyzstep[3]
                ctx[:status][] = "z=[" *
                                 mapreduce(z -> @sprintf("%.3g,", z), *, ctx[:zplanes]) *
                                 "]"
            elseif key == :l
                ctx[:levels] .+= delta * fstep
                ctx[:status][] = "l=[" *
                                 mapreduce(l -> @sprintf("%.3g,", l), *, ctx[:levels]) * "]"
            elseif key == :q
                ctx[:status][] = " "
            end
            #            adjust_planes()
            ctx[:data][] = (g = grid, f = func, x = ctx[:xplanes], y = ctx[:yplanes],
                            z = ctx[:zplanes], l = ctx[:levels], t = ctx[:title])
        end
        ctx[:status] = Observable(" ")
        add_scene!(ctx, makescene3d(ctx))
    else
        ctx[:data][] = (g = grid, f = func, x = ctx[:xplanes], y = ctx[:yplanes],
                        z = ctx[:zplanes], l = ctx[:levels], t = ctx[:title])
    end
    reveal(ctx, TP)
end

# TODO: allow aspect scaling
# if ctx[:aspect]>1.0
#     XMakie.scale!(ctx[:scene],ctx[:aspect],1.0)
# else
#     XMakie.scale!(ctx[:scene],1.0,1.0/ctx[:aspect])
# end

# TODO: use distinguishable colors
# http://juliagraphics.github.io/Colors.jl/stable/colormapsandcolorscales/#Generating-distinguishable-colors-1

# TODO: a priori angles aka pyplot3D
# rect = ctx[:scene]
# azim=ctx[:azim]
# elev=ctx[:elev]
# arr = normalize([cosd(azim/2), 0, sind(azim/2), -sind(azim/2)])
# XMakie.rotate!(rect, XMakie.Quaternionf0(arr...))

# 3 replies
# Julius Krumbiegel  5 hours ago
# try lines(x, y, axis = (limits = lims,)), the other keyword arguments go to the plot
# Julius Krumbiegel  5 hours ago
# although I think it should be targetlimits because the limits are computed from them usually, considering that there might be aspect constraints that should be met or linked axes (edited) 
# Christophe Meyer  4 hours ago
# Thanks!  lines(x, y, axis = (targetlimits = lims,))  indeed makes the limits update.^
# I found that autolimits!(axis) gave good results, even better than me manually computing limits!
