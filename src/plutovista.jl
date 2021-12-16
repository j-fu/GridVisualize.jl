using HypertextLiteral

function initialize!(p::GridVisualizer,::Type{PlutoVistaType})
    PlutoVista=p.context[:Plotter]
    layout=p.context[:layout]
    figres=(p.context[:resolution][1]/layout[2],p.context[:resolution][2]/layout[1])
    for I in CartesianIndices(layout)
        ctx=p.subplots[I] 
        ctx[:figure]=PlutoVista.PlutoVistaPlot(resolution=figres)
        PlutoVista.backend!(ctx[:figure],backend=p.context[:backend],datadim=p.context[:dim])
    end
end


function reveal(p::GridVisualizer,::Type{PlutoVistaType})
    layout=p.context[:layout]
    figwidth=0.95*p.context[:resolution][1]/layout[2]
    l=layout[1]*layout[2]
    subplots=[]
    for i in 1:layout[1]
        for j in 1:layout[2]
            push!(subplots,p.subplots[i,j])
        end
    end
    if l==1
        subplots[1][:figure]
    elseif l==2
        @htl("""<div><div style=" display: inline-block;">
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[1][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[2][:figure])</div>
        </div>""")
    elseif l==3
        @htl("""<div><div style=" display: inline-block;">
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[1][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[2][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[3][:figure])</div>
        </div>""")
    elseif l==4
        @htl("""<div><div style=" display: inline-block;">
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[1][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[2][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[3][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[4][:figure])</div>
        </div>""")
    elseif l==5
        @htl("""<div><div style=" display: inline-block;">
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[1][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[2][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[3][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[4][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[5][:figure])</div>
        </div>""")
    elseif l==6
        @htl("""<div><div style=" display: inline-block;">
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[1][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[2][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[3][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[4][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[5][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[6][:figure])</div>
        </div>""")
    elseif l==7
        @htl("""<div><div style=" display: inline-block;">
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[1][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[2][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[3][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[4][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[5][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[6][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[7][:figure])</div>
        </div>""")
    elseif l==8
        @htl("""<div><div style=" display: inline-block;">
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[1][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[2][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[3][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[4][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[5][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[6][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[7][:figure])</div>
        <div style= "width: $(figwidth)px;  display: inline-block;">$(subplots[8][:figure])</div>
        </div>""")
    end
end

function reveal(ctx::SubVisualizer,TP::Type{PlutoVistaType})
    if ctx[:show]||ctx[:reveal]
        reveal(ctx[:GridVisualizer],TP)
    end
end


function gridplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{1}}, grid)
    PlutoVista=ctx[:Plotter]

    PlutoVista.backend!(ctx[:figure],backend=ctx[:backend],datadim=1)

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
                     limits=ctx[:limits],
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
                        zoom=ctx[:zoom],
                        markers=markers,colormap=cmap,gridscale=ctx[:gridscale],
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
                           colorbarticks=ctx[:colorbarticks],
                           limits=ctx[:limits],
                           backend=ctx[:backend],
                           zoom=ctx[:zoom],
                           gridscale=ctx[:gridscale]
                           )
    reveal(ctx,TP)
end


function vectorplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{2}},grid, func)
    PlutoVista=ctx[:Plotter]
    PlutoVista.backend!(ctx[:figure],backend=ctx[:backend],datadim=2)

    rc,rv=vectorsample(grid,func,spacing=ctx[:spacing], offset=ctx[:offset])
    qc,qv=quiverdata(rc,rv;vscale=ctx[:vscale],vnormalize=ctx[:vnormalize])

    PlutoVista.quiver2d!(ctx[:figure],qc,qv)
    reveal(ctx,TP)
end

function streamplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{2}},grid, func) end


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
                        zoom=ctx[:zoom],
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
                           levelalpha=ctx[:levelalpha],
                           zoom=ctx[:zoom]
                           )
    reveal(ctx,TP)
end
