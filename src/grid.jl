"""
    ndgrid(x::AbstractVector...) -> Tuple{AbstractArray...}
return `nd` carstesian product grid of input vectors in `ij` index style.
"""
ndgrid(x::AbstractVector; dim=2) = dim == 1 ? (x,) : ndgrid(ntuple(i -> x, dim))
ndgrid(x::AbstractVector...; dim=length(x)) =
    ndgrid((x..., ntuple(i -> x[end], dim - length(x))...))

function ndgrid(x::NTuple{N,AbstractVector}) where {N}
    ntuple(i -> [@inbounds v[i] for v in Iterators.product(x...)], Val(N))
end

"""
    meshgrid(x::AbstractVector,[y::AbstractVector]) -> Tuple{AbstractArray...}
return `2d` carstesian product grid of input vectors in `xy` index style.
"""
meshgrid(x::AbstractVector) = meshgrid(x, x)
meshgrid(x::NTuple{2,AbstractVector}) = meshgrid(x...)
function meshgrid(x::AbstractVector, y::AbstractVector)
    (
        [@inbounds v[2] for v in Iterators.product(y, x)],
        [@inbounds v[1] for v in Iterators.product(y, x)]
    )
end
