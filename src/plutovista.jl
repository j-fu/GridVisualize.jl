

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


gridplot!(ctx, TP::Type{PlutoVistaType}, ::Type{Val{1}}, grid)=nothing
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





