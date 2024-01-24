struct LinearSimplices{D,Tc,Ti,Tf} <: LinearSimplexIterator{D}
    coord::Matrix{Tc}
    cellnodes::Matrix{Ti}
    values::Vector{Tf}
    range::StepRange{Int,Int}
    ichunk::Int
end

function LinearSimplices(coord::Matrix{Tc},cn::Matrix{Ti},f::Vector{Tf};nthreads=Threads.nthreads()) where {Tc,Ti,Tf}
    ncells=size(cn,2)
    dim=size(coord,1)
    map(chunks(1:ncells,nthreads)) do c
	LinearSimplices{dim,Tc,Ti,Tf}(coord,cn,f,c...)
    end
end	

function LinearSimplices(g::ExtendableGrid,f::Vector;nthreads=1)
	LinearSimplices(g[Coordinates],g[CellNodes],f;nthreads)
end

function Base.iterate(linear_simplices::LinearSimplices{D}, args...) where D
    (;coord,cellnodes,values,range)=linear_simplices
    iter=iterate(range,args...)
    isnothing(iter) && return nothing 
    (icell,state)=iter
    @views s=LinearSimplex(Val{D},
			   coord[:,cellnodes[:,icell]],
			   values[cellnodes[:,icell]])
    (s,state)
end
