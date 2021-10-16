function initialize!(p, ::Type{PyPlotType})
    PyPlot=p.context[:Plotter]
    PyPlot.PyObject(PyPlot.axes3D)# see https://github.com/JuliaPy/PyPlot.jl/issues/351
    if !haskey(p.context,:figure)
        res=p.context[:resolution]
        p.context[:figure]=PyPlot.figure(p.context[:fignumber],dpi=100)
        p.context[:figure].set_size_inches(res[1]/100,res[2]/100,forward=true)
        for ctx in p.subplots
            ctx[:figure]=p.context[:figure]
        end
    end
    if p.context[:clear]
        p.context[:figure].clf()
        p.context[:revealed]=false
    end
end

function save(fname,p,::Type{PyPlotType})
    p.context[:figure].savefig(fname)
end

function save(fname,scene,PyPlot,::Type{PyPlotType})
    scene.savefig(fname)
end

function reveal(p::GridVisualizer,::Type{PyPlotType})
    p.context[:revealed]=true
    p.Plotter.tight_layout()
    if !(isdefined(Main,:PlutoRunner))&& isinteractive()
        p.Plotter.pause(1.0e-10)
        p.Plotter.draw()
        sleep(1.0e-3)
    end
    p.context[:figure]
end

function reveal(ctx::SubVisualizer,TP::Type{PyPlotType})
    yield()
    if ctx[:show]||ctx[:reveal]
        reveal(ctx[:GridVisualizer],TP)
    end
end


#translate Julia attribute symbols to pyplot-speak
const mshapes=Dict(
    :dtriangle => "v",
    :utriangle => "^",
    :rtriangle => ">",
    :ltriangle => "^",
    :circle => "o",
    :square => "s",
    :cross => "+",
    :+ => "+",
    :xcross => "x",
    :x => "x",
    :diamond => "D",
    :star5 => "*",
    :pentagon => "p",
    :hexagon => "h",
)

const lstyles=Dict(
    :solid => "-",
    :dot => "dotted",
    :dash => "--",
    :dashdot => "-.",
    :dashdotdot => (0, (3, 1, 1, 1))
)

const leglocs=Dict(
    :none => "",
    :best => "best",
    :lt => "upper left",
    :ct => "upper center",
    :rt => "upper right",
    :lc => "center left",
    :cc => "center center",
    :rc => "center right",
    :lb => "lower left",
    :cb => "lower center",
    :rb => "lower right"
)




"""
$(SIGNATURES)
Return tridata to be splatted to PyPlot calls
"""
function tridata(grid)
    coord=grid[Coordinates]
    cellnodes=Matrix(grid[CellNodes])
    coord[1,:], coord[2,:],transpose(cellnodes.-1)
end

# Interfaces to Colors/Colorschemes
plaincolormap(ctx)=colorschemes[ctx[:colormap]].colors



### 1D grid
function gridplot!(ctx, TP::Type{PyPlotType}, ::Type{Val{1}}, grid)
    PyPlot=ctx[:Plotter]

    if !haskey(ctx,:ax)
        ctx[:ax]=ctx[:figure].add_subplot(ctx[:layout]...,ctx[:iplot])
    end
    if ctx[:clear]
        ctx[:ax].cla()
    end
    ax=ctx[:ax]
    fig=ctx[:figure]

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
    ax.grid(true)
    ax.get_yaxis().set_ticks([])
    ax.set_ylim(-5*h,xmax-xmin)
    cmap=region_cmap(ncellregions)

    for icell=1:num_cells(grid)
        ireg=cellregions[icell]
        label = crflag[ireg] ? "c$(ireg)" : ""
        crflag[ireg]=false
        
        x1=coord[1,cellnodes[1,icell]]
        x2=coord[1,cellnodes[2,icell]]
        ax.plot([x1,x2],[0,0],linewidth=3.0,color=rgbtuple(cmap[cellregions[icell]]),label=label)
        ax.plot([x1,x1],[-h,h],linewidth=ctx[:linewidth],color="k",label="")
        ax.plot([x2,x2],[-h,h],linewidth=ctx[:linewidth],color="k",label="")
    end
    
    cmap=bregion_cmap(nbfaceregions)
    for ibface=1:num_bfaces(grid)
        ireg=bfaceregions[ibface]
        if ireg >0
            label = brflag[ireg] ? "b$(ireg)" : ""
            brflag[ireg]=false
            x1=coord[1,bfacenodes[1,ibface]]
            ax.plot([x1,x1],[-2*h,2*h],linewidth=3.0,color=rgbtuple(cmap[ireg]),label=label)
        end
    end
    if ctx[:legend]!=:none
        ax.legend(loc=leglocs[ctx[:legend]],ncol=5)
    end
    reveal(ctx,TP)
end



### 2D grid
function gridplot!(ctx, TP::Type{PyPlotType}, ::Type{Val{2}},grid)
    PyPlot=ctx[:Plotter]
    if !haskey(ctx,:ax)
        ctx[:ax]=ctx[:figure].add_subplot(ctx[:layout]...,ctx[:iplot])
    end
    if ctx[:clear]
        ctx[:ax].cla()
    end
    ax=ctx[:ax]
    fig=ctx[:figure]
    cellregions=grid[CellRegions]
    cellnodes=grid[CellNodes]
    coord=grid[Coordinates]
    ncellregions=grid[NumCellRegions]
    nbfaceregions=grid[NumBFaceRegions]
    ncellregions=grid[NumCellRegions]
    if nbfaceregions>0
        bfacenodes=grid[BFaceNodes]
        bfaceregions=grid[BFaceRegions]
    end
    
    crflag=ones(Bool,ncellregions)
    brflag=ones(Bool,nbfaceregions)
    ax.set_aspect(ctx[:aspect])
    tridat=tridata(grid)
    cmap=region_cmap(ncellregions)
    cdata=ax.tripcolor(tridat...,
                       facecolors=grid[CellRegions],
                       cmap=PyPlot.ColorMap(cmap,length(cmap)),
                       vmin=1.0,
                       vmax=length(cmap)
                       )
    if ctx[:colorbar]==:horizontal
        cbar=fig.colorbar(cdata,ax=ax,ticks=collect(1:length(cmap)),orientation="horizontal")
    end

    if ctx[:colorbar]==:vertical
        cbar=fig.colorbar(cdata,ax=ax,ticks=collect(1:length(cmap)),orientation="vertical")
    end
    
    ax.triplot(tridat...,color="k",linewidth=ctx[:linewidth])


    if nbfaceregions>0 
        cmap=bregion_cmap(nbfaceregions)
        # see https://gist.github.com/gizmaa/7214002
        xc=[coord[:,bfacenodes[1,i]] for i=1:num_sources(bfacenodes)]
        yc=[coord[:,bfacenodes[2,i]] for i=1:num_sources(bfacenodes)]
        rgb=[rgbtuple(cmap[bfaceregions[i]]) for i=1:length(bfaceregions)]
        ax.add_collection(PyPlot.matplotlib.collections.LineCollection(collect(zip(xc,yc)),colors=rgb,linewidth=3))
        for i=1:nbfaceregions
            ax.plot(coord[:,1], coord[:,1],label="$(i)", color=rgbtuple(cmap[i]))
        end
    end
    if ctx[:legend]!=:none
        ax.legend(loc=leglocs[ctx[:legend]])
    end
    reveal(ctx,TP)
end


### 3D Grid
function gridplot!(ctx, TP::Type{PyPlotType}, ::Type{Val{3}},grid)
    # See https://jakevdp.github.io/PythonDataScienceHandbook/04.12-three-dimensional-plotting.html

    PyPlot=ctx[:Plotter]
    if !haskey(ctx,:ax)
        ctx[:ax]=ctx[:figure].add_subplot(ctx[:layout]...,ctx[:iplot],projection="3d")
    end


    ax=ctx[:ax]

    if ctx[:clear]
        ctx[:ax].cla()
    end


    fig=ctx[:figure]
    
    nregions=num_cellregions(grid)
    nbregions=num_bfaceregions(grid)

    xyzmin=zeros(3)
    xyzmax=ones(3)
    coord=grid[Coordinates]
    @views for idim=1:3
        xyzmin[idim]=minimum(coord[idim,:])
        xyzmax[idim]=maximum(coord[idim,:])
    end

    ax.set_xlim3d(xyzmin[1],xyzmax[1])
    ax.set_ylim3d(xyzmin[2],xyzmax[2])
    ax.set_zlim3d(xyzmin[3],xyzmax[3])
    ax.view_init(ctx[:elev],ctx[:azim])

    cmap=region_cmap(nregions)
    bcmap=bregion_cmap(nbregions)

    xyzcut=[ctx[:xplanes][1],ctx[:yplanes][1],ctx[:zplanes][1]]
    
    if ctx[:interior]
        regpoints0,regfacets0=extract_visible_cells3D(grid,
                                                      xyzcut,
                                                      primepoints=hcat(xyzmin,xyzmax)
                                                      )
        regfacets=[reshape(reinterpret(Int32,regfacets0[i]),(3,length(regfacets0[i]))) for i=1:nregions]
        regpoints=[reshape(reinterpret(Float32,regpoints0[i]),(3,length(regpoints0[i]))) for i=1:nregions]

        for ireg=1:nregions
            if size(regfacets[ireg],2)>0
                ax.plot_trisurf(regpoints[ireg][1,:],regpoints[ireg][2,:],transpose(regfacets[ireg].-1),regpoints[ireg][3,:],
                                color=rgbtuple(cmap[ireg]),edgecolors=:black,linewidth=0.5)
            end
        end
    end

    
    
    bregpoints0,bregfacets0=extract_visible_bfaces3D(grid,
                                                     xyzcut,
                                                     primepoints=hcat(xyzmin,xyzmax)
                                                     )
    bregfacets=[reshape(reinterpret(Int32,bregfacets0[i]),(3,length(bregfacets0[i]))) for i=1:nbregions]
    bregpoints=[reshape(reinterpret(Float32,bregpoints0[i]),(3,length(bregpoints0[i]))) for i=1:nbregions]
    for ireg=1:nbregions
        if size(bregfacets[ireg],2)>0
            ax.plot_trisurf(bregpoints[ireg][1,:],bregpoints[ireg][2,:],transpose(bregfacets[ireg].-1),bregpoints[ireg][3,:],
                            color=rgbtuple(bcmap[ireg]),edgecolors=:black,linewidth=0.5)
        end
    end
    



    
    if ctx[:legend]!=:none
        ax.legend(loc=leglocs[ctx[:legend]])
    end
    reveal(ctx,TP)
end




### 1D Function
function scalarplot!(ctx, TP::Type{PyPlotType}, ::Type{Val{1}},grid, func::AbstractVector)
    PyPlot=ctx[:Plotter]
    if !haskey(ctx,:ax)
        ctx[:ax]=ctx[:figure].add_subplot(ctx[:layout]...,ctx[:iplot])
    end
    if ctx[:clear]
        ctx[:ax].cla()
        xlimits=ctx[:xlimits]
        ylimits=ctx[:limits]
        ax=ctx[:ax]
        
        if xlimits[1]<xlimits[2]
            ax.set_xlim(xlimits...)
        end
        if ylimits[1]<ylimits[2]
            ax.set_ylim(ylimits...)
        end
        ax.grid()
        ax.set_title(ctx[:title])
    end
    ax=ctx[:ax]
    fig=ctx[:figure]
    
    cellnodes=grid[CellNodes]
    coord=grid[Coordinates]

    pplot=ax.plot
    if ctx[:xscale]==:log 
        if ctx[:yscale]==:log
            pplot=ax.loglog
        else
            pplot=ax.semilogx
        end
    end
    if ctx[:yscale]==:log 
        if ctx[:xscale]==:log
            pplot=ax.loglog
        else
            pplot=ax.semilogy
        end
    end


    
    if ctx[:cellwise] # not checked
        for icell=1:num_cells(grid)
            i1=cellnodes[1,icell]
            i2=cellnodes[2,icell]
            x1=coord[1,i1]
            x2=coord[1,i2]
            if icell==1
                ax.plot([x1,x2],[func[i1],func[i2]],color=rgbtuple(ctx[:color]),label=ctx[:label])
            else
                ax.plot([x1,x2],[func[i1],func[i2]],color=rgbtuple(ctx[:color]))
            end                
        end
    else
        if ctx[:markershape]==:none
            if ctx[:label]!==""
                pplot(coord[1,:],func,
                        linestyle=lstyles[ctx[:linestyle]],
                        color=rgbtuple(ctx[:color]),
                        linewidth=ctx[:linewidth],
                        label=ctx[:label])
            else
                pplot(coord[1,:],func,
                        linestyle=lstyles[ctx[:linestyle]],
                        linewidth=ctx[:linewidth],
                        color=rgbtuple(ctx[:color]))
            end
        else
            if ctx[:label]!==""
                pplot(coord[1,:],func,
                      linestyle=lstyles[ctx[:linestyle]],
                      color=rgbtuple(ctx[:color]),
                      label=ctx[:label],
                      marker=mshapes[ctx[:markershape]],
                      markevery=ctx[:markevery],
                      markersize=ctx[:markersize],
                      linewidth=ctx[:linewidth]
                      )
            else
                pplot(coord[1,:],func,
                      linestyle=lstyles[ctx[:linestyle]],
                      color=rgbtuple(ctx[:color]),
                      marker=mshapes[ctx[:markershape]],
                      markevery=ctx[:markevery],
                      markersize=ctx[:markersize],
                      linewidth=ctx[:linewidth]
                      )
            end                
        end
        # points=[Point2f0(coord[1,i],func[i]) for i=1:length(func)]
        # Hard to get this robust, as we need to get axislimits
        # mpoints=markerpoints(points,ctx[:markers],Diagonal([1,1]))
        # ampoints=reshape(reinterpret(Float32,mpoints),(2,length(mpoints)))
        # ax.scatter(ampoints[1,:], ampoints[2,:],color=ctx[:color],label="")
        
    end
    ax.grid(true)
    ax.set_xlabel(ctx[:xlabel])
    ax.set_ylabel(ctx[:ylabel])
    if ctx[:legend]!=:none
        ax.legend(loc=leglocs[ctx[:legend]])
    end
    
    reveal(ctx,TP)
end

### 2D Function
function scalarplot!(ctx, TP::Type{PyPlotType}, ::Type{Val{2}},grid, func)
    PyPlot=ctx[:Plotter]
    if !haskey(ctx,:ax)
        ctx[:ax]=ctx[:figure].add_subplot(ctx[:layout]...,ctx[:iplot])
    end
    if ctx[:clear]
        if haskey(ctx,:cbar)
            ctx[:cbar].remove()
        end
        ctx[:ax].remove()
        ctx[:ax]=ctx[:figure].add_subplot(ctx[:layout]...,ctx[:iplot])
    end
    
    ax=ctx[:ax]
    fig=ctx[:figure]
    ax.set_aspect(ctx[:aspect])
    ax.set_title(ctx[:title])


    isolines,crange=isolevels(ctx,func)
    colorlevels=collect(crange[1]:(crange[2]-crange[1])/(ctx[:colorlevels]-1):crange[2])

    if !haskey(ctx,:grid) || !seemingly_equal(ctx[:grid],grid)
        ctx[:grid]=grid
        ctx[:tridata]=tridata(grid)
    end
    cnt=ax.tricontourf(ctx[:tridata]...,func;levels=colorlevels,cmap=PyPlot.ColorMap(plaincolormap(ctx)))
    for c in cnt.collections
        c.set_edgecolor("face")
    end
    ax.tricontour(ctx[:tridata]...,func,colors="k",levels=isolines)


    
    if ctx[:colorbar]==:horizontal
        ctx[:cbar]=fig.colorbar(cnt,ax=ax,ticks=isolines,boundaries=colorlevels, orientation="horizontal")
    end

    if ctx[:colorbar]==:vertical
        ctx[:cbar]=fig.colorbar(cnt,ax=ax,ticks=isolines,boundaries=colorlevels, orientation="vertical")
    end

    ax.set_xlabel(ctx[:xlabel])

    ax.set_ylabel(ctx[:ylabel])
    
    reveal(ctx,TP)
end

function scalarplot!(ctx, TP::Type{PyPlotType}, ::Type{Val{3}},grid,func)

    PyPlot=ctx[:Plotter]
    if !haskey(ctx,:ax)
        ctx[:ax]=ctx[:figure].add_subplot(ctx[:layout]...,ctx[:iplot],projection="3d")
    end
    ax=ctx[:ax]
    fig=ctx[:figure]
    
    nregions=num_cellregions(grid)
    nbregions=num_bfaceregions(grid)

    xyzmin=zeros(3)
    xyzmax=ones(3)
    coord=grid[Coordinates]
    @views for idim=1:3
        xyzmin[idim]=minimum(coord[idim,:])
        xyzmax[idim]=maximum(coord[idim,:])
    end
    xyzcut=[ctx[:xplanes],ctx[:yplanes],ctx[:zplanes]]
    
    levels,crange=isolevels(ctx,func)

    planes=makeplanes(xyzmin,xyzmax,ctx[:xplanes],ctx[:yplanes],ctx[:zplanes])

    ccoord0,faces0,values=marching_tetrahedra(grid,func,planes,levels)

    faces=reshape(reinterpret(Int32,faces0),(3,length(faces0)))
    ccoord=reshape(reinterpret(Float32,ccoord0),(3,length(ccoord0)))

    nfaces=size(faces,2)
    if nfaces>0
        colors=zeros(nfaces)
        for i=1:nfaces
            colors[i]=(values[faces[1,i]]+values[faces[2,i]]+values[faces[3,i]])/3
        end
        # thx, https://stackoverflow.com/a/24229480/8922290 
        collec=ctx[:ax].plot_trisurf(ccoord[1,:],ccoord[2,:],transpose(faces.-1),ccoord[3,:],
                                     cmap=PyPlot.ColorMap(plaincolormap(ctx)),
                                     vmin=crange[1],
                                     vmax=crange[2])
        collec.set_array(colors)
        collec.autoscale()
    end

    ax.set_xlim3d(xyzmin[1],xyzmax[1])
    ax.set_ylim3d(xyzmin[2],xyzmax[2])
    ax.set_zlim3d(xyzmin[3],xyzmax[3])
    ax.view_init(ctx[:elev],ctx[:azim])
    
    ax.set_title(ctx[:title])
    
    if ctx[:legend]!=:none
        ax.legend(loc=leglocs[ctx[:legend]])
    end
    reveal(ctx,TP)
end

### 2D Vector
function vectorplot!(ctx, TP::Type{PyPlotType}, ::Type{Val{2}},grid, func)
    PyPlot=ctx[:Plotter]
    if !haskey(ctx,:ax)
        ctx[:ax]=ctx[:figure].add_subplot(ctx[:layout]...,ctx[:iplot])
    end
    if ctx[:clear]
        if haskey(ctx,:cbar)
            ctx[:cbar].remove()
        end
        ctx[:ax].remove()
        ctx[:ax]=ctx[:figure].add_subplot(ctx[:layout]...,ctx[:iplot])
    end
    
    ax=ctx[:ax]
    fig=ctx[:figure]
    ax.set_aspect(ctx[:aspect])
    ax.set_title(ctx[:title])

    rc,rv=vectorsample(grid,func,spacing=ctx[:spacing], offset=ctx[:offset])
    qc,qv=quiverdata(rc,rv;vscale=ctx[:vscale],vnormalize=ctx[:vnormalize])

    ax.quiver(qc[1,:], qc[2,:], qv[1,:],qv[2,:])
    ax.set_xlabel(ctx[:xlabel])
    ax.set_ylabel(ctx[:ylabel])
    
    reveal(ctx,TP)
end
