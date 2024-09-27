using JlMatlab
using BenchmarkTools

mgrid1(x) = mgrid1(x, x)
mgrid1(x::AbstractVector, y::AbstractVector) = (
    [@inbounds x[j] for i in eachindex(x), j in eachindex(y)],
    [@inbounds y[i] for i in eachindex(x), j in eachindex(y)]
)
mgrid2(x) = mgrid2(x, x)
mgrid2(x::AbstractVector, y::AbstractVector) = (
    [x[j] for i in eachindex(x), j in eachindex(y)],
    [y[i] for i in eachindex(x), j in eachindex(y)]
)

mgrid3(x) = mgrid3(x, x)
mgrid3(x::AbstractVector, y::AbstractVector) = (
    [v[1] for v in Iterators.product(x, y)],
    [v[2] for v in Iterators.product(x, y)],
)

mgrid4(x) = mgrid4(x, x)
mgrid4(x::AbstractVector, y::AbstractVector) = (
    [@inbounds v[1] for v in Iterators.product(x, y)],
    [@inbounds v[2] for v in Iterators.product(x, y)],
)

@btime mgrid1(1:100, 1:100)
@btime mgrid2(1:100, 1:100)
@btime mgrid3(1:100, 1:100)
@btime mgrid4(1:100, 1:100)

@btime ndgrid(1:100, 1:100)
@btime meshgrid(1:100, 1:100)

;