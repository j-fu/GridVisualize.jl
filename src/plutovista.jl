

function initialize!(p::GridVisualizer,::Type{PlutoVistaType})
    PlutoVista=p.context[:Plotter]
    layout=p.context[:layout]
    @assert(layout==(1,1))
    p.context[:scene]=PlutoVista.PlutoVistaPlot(resolution=p.context[:resolution])
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
        
        PlutoVista.plot!(ctx[:figure],[x1,x2],[0,0],linewidth=3.0,color=rgbtuple(cmap[cellregions[icell]]),label=label)
        PlutoVista.plot!(ctx[:figure],[x1,x1],[-h,h],linewidth=ctx[:linewidth],color=:black)
        PlutoVista.plot!(ctx[:figure],[x2,x2],[-h,h],linewidth=ctx[:linewidth],color=:black)
    end
    
    cmap=bregion_cmap(nbfaceregions)
    for ibface=1:num_bfaces(grid)
        ireg=bfaceregions[ibface]
        if ireg >0
            label = brflag[ireg] ? "b$(ireg)" : ""
            brflag[ireg]=false
            x1=coord[1,bfacenodes[1,ibface]]
            PlutoVista.plot!(ctx[:figure],[x1,x1],[-2*h,2*h],linewidth=3.0,color=rgbtuple(cmap[ireg]),label=label,legend=leglocs[ctx[:legend]])
        end
    end
    reveal(ctx,TP)
end



function scalarplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{1}}, grid,func)
    PlutoVista=ctx[:Plotter]
    coord=grid[Coordinates]
    PlutoVista.plot!(ctx[:figure],coord[1,:],func,
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
                     ylimits=ctx[:flimits],
                     clear=ctx[:clear]
                     )
    reveal(ctx,TP)
end

gridplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{2}}, grid)=nothing
function scalarplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{2}}, grid,func)
    PlutoVista=ctx[:Plotter]
    pts=grid[Coordinates]
    tris=grid[CellNodes]

    isolines=ctx[:isolines]
    fmin,fmax=ctx[:flimits]

    if fmin<fmax
        isolines=collect(range(fmin,fmax,length=isolines))
    end
    PlutoVista.tricontour!(ctx[:figure],pts,tris,func,
                           colormap=ctx[:colormap],
                           backend=ctx[:backend],
                           isolines=isolines
                           )
    reveal(ctx,TP)

end

gridplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{3}}, grid)=nothing
scalarplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{3}}, grid,func)=nothing





