"""
    ndgrid(x::AbstractVector...) -> Tuple{AbstractArray...}
return `nd` carstesian product grid of input vectors in `ij` index style.
"""
ndgrid(x::AbstractVector; dim::Integer=2) = dim == 1 ? (x,) : ndgrid(ntuple(i -> x, dim))
ndgrid(x::AbstractVector...; dim::Integer) = (
    n = dim - length(x);
    n <= 0 ? ndgrid(x...) :
    n == 1 ? ndgrid((x..., x[end])) :
    n == 2 ? ndgrid((x..., x[end], x[end])) :
    n == 3 ? ndgrid((x..., x[end], x[end], x[end])) :
    n == 4 ? ndgrid((x..., x[end], x[end], x[end], x[end])) :
    ndgrid((x..., ntuple(i -> x[end], Int(dim) - length(x))...))
)

ndgrid(x::AbstractVector, y::AbstractVector) = (
    [@inbounds v[1] for v in Iterators.product(x, y)],
    [@inbounds v[2] for v in Iterators.product(x, y)]
)

ndgrid(x::AbstractVector, y::AbstractVector, z::AbstractVector) = (
    [@inbounds v[1] for v in Iterators.product(x, y, z)],
    [@inbounds v[2] for v in Iterators.product(x, y, z)],
    [@inbounds v[3] for v in Iterators.product(x, y, z)]
)

ndgrid(x::AbstractVector, y::AbstractVector, z::AbstractVector, w::AbstractVector) = (
    [@inbounds v[1] for v in Iterators.product(x, y, z, w)],
    [@inbounds v[2] for v in Iterators.product(x, y, z, w)],
    [@inbounds v[3] for v in Iterators.product(x, y, z, w)],
    [@inbounds v[4] for v in Iterators.product(x, y, z, w)]
)

ndgrid(x::AbstractVector...) = ndgrid(x)
ndgrid(x::NTuple{N,AbstractVector}) where {N} =
    ntuple(i -> [@inbounds v[i] for v in Iterators.product(x...)], Val(N))

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
