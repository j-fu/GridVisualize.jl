function initialize!(p::GridVisualizer,::Type{PlutoVistaType})
    PlutoVista=p.context[:Plotter]
    layout=p.context[:layout]
    @assert(layout==(1,1))
    p.context[:scene]=PlutoVista.PlutoVistaPlot(resolution=p.context[:resolution])
    PlutoVista.backend!(p.context[:scene],backend=p.context[:backend],datadim=p.context[:dim])
    for I in CartesianIndices(layout)
        ctx=p.subplots[I]
        ctx[:figure]=p.context[:scene]
    end
end


function reveal(p::GridVisualizer,::Type{PlutoVistaType})
    p.context[:scene]
end

function reveal(ctx::SubVisualizer,TP::Type{PlutoVistaType})
    if ctx[:show]||ctx[:reveal]
        reveal(ctx[:GridVisualizer],TP)
    end
end


function gridplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{1}}, grid)
    PlutoVista=ctx[:Plotter]

    Plutovista.backend!(ctx[:figure],backend=ctx[:backend],datadim=1)

    coord=grid[Coordinates]
    cellregions=grid[CellRegions]
    cellnodes=grid[CellNodes]
    coord=grid[Coordinates]
    ncellregions=grid[NumCellRegions]
    bfacenodes=grid[BFaceNodes]
    bfaceregions=grid[BFaceRegions]
    nbfaceregions=grid[NumBFaceRegions]
    ncellregions=grid[NumCellRegions]
    
    crflag=ones(Bool,ncellregions)
    brflag=ones(Bool,nbfaceregions)
    
    xmin=minimum(coord)
    xmax=maximum(coord)
    h=(xmax-xmin)/20.0
    
    #    ax.set_aspect(ctx[:aspect])
    #    ax.get_yaxis().set_ticks([])
    #    ax.set_ylim(-5*h,xmax-xmin)
    cmap=region_cmap(ncellregions)
    
    for icell=1:num_cells(grid)
        ireg=cellregions[icell]
        label = crflag[ireg] ? "c$(ireg)" : ""
        crflag[ireg]=false
        
        x1=coord[1,cellnodes[1,icell]]
        x2=coord[1,cellnodes[2,icell]]
        
        PlutoVista.plot!(ctx[:figure],[x1,x2],[0,0],clear=false,linewidth=3.0,color=rgbtuple(cmap[cellregions[icell]]),label=label)
        PlutoVista.plot!(ctx[:figure],[x1,x1],[-h,h],clear=false,linewidth=ctx[:linewidth],color=:black)
        PlutoVista.plot!(ctx[:figure],[x2,x2],[-h,h],clear=false,linewidth=ctx[:linewidth],color=:black)
    end
    
    cmap=bregion_cmap(nbfaceregions)
    for ibface=1:num_bfaces(grid)
        ireg=bfaceregions[ibface]
        if ireg >0
            label = brflag[ireg] ? "b$(ireg)" : ""
            brflag[ireg]=false
            x1=coord[1,bfacenodes[1,ibface]]
            PlutoVista.plot!(ctx[:figure],[x1,x1],[-2*h,2*h],clear=false,linewidth=3.0,color=rgbtuple(cmap[ireg]),label=label,legend=leglocs[ctx[:legend]])
        end
    end

    reveal(ctx,TP)
end



function scalarplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{1}}, grid,func)
    PlutoVista=ctx[:Plotter]
    coord=grid[Coordinates]
    PlutoVista.backend!(ctx[:figure],backend=ctx[:backend],datadim=1)
    PlutoVista.plot!(ctx[:figure],
                     coord[1,:],
                     func,
                     color=ctx[:color],
                     markertype=ctx[:markershape],
                     markercount=length(func)÷ctx[:markevery],
                     linestyle=ctx[:linestyle],
                     xlabel=ctx[:xlabel],
                     ylabel=ctx[:ylabel],
                     label=ctx[:label],
                     linewidth=ctx[:linewidth],
                     legend=ctx[:legend],
                     xlimits=ctx[:xlimits],
                     ylimits=ctx[:limits],
                     clear=ctx[:clear],
                     title=ctx[:title],
                     xscale=ctx[:xscale],
                     yscale=ctx[:yscale]
                     )
    reveal(ctx,TP)
end

function gridplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{2}}, grid)
    nregions=num_cellregions(grid)
    nbregions=num_bfaceregions(grid)
    cmap=region_cmap(nregions)
    bcmap=bregion_cmap(nbregions)

    PlutoVista=ctx[:Plotter]
    pts=grid[Coordinates]
    tris=grid[CellNodes]
    markers=grid[CellRegions]
    edges=grid[BFaceNodes]
    edgemarkers=grid[BFaceRegions]
    
    PlutoVista.backend!(ctx[:figure],backend=ctx[:backend],datadim=2)
    PlutoVista.trimesh!(ctx[:figure],pts,tris,
                        markers=markers,colormap=cmap,
                        edges=edges,edgemarkers=edgemarkers,edgecolormap=bcmap)
    reveal(ctx,TP)
end


function scalarplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{2}}, grid,func)
    PlutoVista=ctx[:Plotter]
    PlutoVista.backend!(ctx[:figure],backend=ctx[:backend],datadim=2)
    PlutoVista.tricontour!(ctx[:figure],
                           grid[Coordinates],
                           grid[CellNodes],
                           func,
                           colormap=ctx[:colormap],
                           levels=ctx[:levels],
                           limits=ctx[:limits]
                           )
    reveal(ctx,TP)
end


function vectorplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{2}},grid, func)
    PlutoVista=ctx[:Plotter]
    PlutoVista.backend!(ctx[:figure],backend=ctx[:backend],datadim=2)
    qc,qv=vectorsample(grid,func,spacing=ctx[:spacing], offset=ctx[:offset],vscale=ctx[:vscale],vnormalize=ctx[:vnormalize])
    PlutoVista.quiver2d!(ctx[:figure],qc,qv)
    reveal(ctx,TP)
end



function gridplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{3}}, grid)

    nregions=num_cellregions(grid)
    nbregions=num_bfaceregions(grid)
    cmap=region_cmap(nregions)
    bcmap=bregion_cmap(nbregions)
    
    PlutoVista=ctx[:Plotter]
    pts=grid[Coordinates]
    tris=grid[CellNodes]
    faces=grid[BFaceNodes]
    markers=grid[CellRegions]
    facemarkers=grid[BFaceRegions]
    
    PlutoVista.backend!(ctx[:figure],backend=ctx[:backend],datadim=3)
    PlutoVista.tetmesh!(ctx[:figure],pts,tris,
                        xplanes=ctx[:xplanes],
                        yplanes=ctx[:yplanes],
                        zplanes=ctx[:zplanes],
                        markers=markers,colormap=cmap,
                        faces=faces,facemarkers=facemarkers,facecolormap=bcmap,
                        outlinealpha=ctx[:outlinealpha])
    reveal(ctx,TP)
end

function scalarplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{3}}, grid,func)
    PlutoVista=ctx[:Plotter]
    nbregions=num_bfaceregions(grid)
    bcmap=bregion_cmap(nbregions)
    PlutoVista.backend!(ctx[:figure],backend=ctx[:backend],datadim=3)
    PlutoVista.tetcontour!(ctx[:figure],
                           grid[Coordinates],
                           grid[CellNodes],
                           func;
                           levels=ctx[:levels],
                           colormap=ctx[:colormap],
                           xplanes=ctx[:xplanes],
                           yplanes=ctx[:yplanes],
                           zplanes=ctx[:zplanes],
                           limits=ctx[:limits],
                           faces=grid[BFaceNodes],
                           facemarkers=grid[BFaceRegions],
                           facecolormap=bcmap,
                           outlinealpha=ctx[:outlinealpha],
                           levelalpha=ctx[:levelalpha]
                           )
    reveal(ctx,TP)
end
