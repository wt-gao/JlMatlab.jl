"""
    ndgrid(x::AbstractVector...) -> Tuple{AbstractArray...}
return `nd` carstesian product of input vectors in `ij` index style.
"""
ndgrid(x::AbstractVector) = x
ndgrid(x::AbstractVector...) = ndgrid(x)

function ndgrid(x::NTuple{N,AbstractVector}) where {N}
    ntuple(i -> [v[i] for v in Iterators.product(x...)], Val(N))
end

"""
    meshgrid(x::AbstractVector,[y::AbstractVector]) -> Tuple{AbstractArray...}
return `2d` carstesian product of input vectors in `xy` index style.
"""
meshgrid(x::AbstractVector) = meshgrid(x, x)

function meshgrid(x::AbstractVector, y::AbstractVector)
    nx, ny = length(x), length(y)
    ([x[j] for i in 1:ny, j in 1:nx], [y[i] for i in 1:ny, j in 1:nx])
end
