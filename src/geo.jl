"""
    inpolygon(
        xv::AbstractVector{<:Real},
        yv::AbstractVector{<:Real},
        xq::AbstractVector{<:Real},
        yq::AbstractVector{<:Real}) -> Vector{Bool}
Test quiried points `xq` and `yq` if they are inside the polygon defined by `xv` and `yv`.
`true` if inside, `false` otherwise.
"""
function inpolygon(
    xv::AbstractVector{<:Real},
    yv::AbstractVector{<:Real},
    xq::AbstractVector{<:Real},
    yq::AbstractVector{<:Real})

    np = length(xq)
    np != length(yq) && throw(ArgumentError("xq and yq must have the same length"))

    edge = _check_polyloop(xv, yv)

    inpoly(x, y) = begin
        D = 0
        @inbounds for ie in edge
            !(yv[ie[1]] > y ⊻ yv[ie[2]] > y) && continue
            d = orient(x, y, xv[ie[1]], yv[ie[1]], xv[ie[2]], yv[ie[2]])
            d == 0 && return (true, true)
            D += d
        end
        (D != 0, false)
    end

    in_on = inpoly.(xq, yq)
    ([v[1] for v in in_on], [v[2] for v in in_on])
end

function orient(x1::Real, y1::Real, x2::Real, y2::Real, x3::Real, y3::Real)::Int
    det = (x2 - x1) * (y3 - y1) - (x3 - x1) * (y2 - y1)
    det ≈ 0 && return 0
    det > 0 ? 1 : -1
end

function _check_polyloop(xv::AbstractVector{<:Real}, yv::AbstractVector{<:Real})
    n = length(xv)
    n != length(yv) && throw(ArgumentError("xv and yv must have the same length"))
    n < 3 && throw(ArgumentError("xv and yv must have at least 3 elements"))

    nanix = isnan.(xv)
    any(nanix ⊻ isnan.(yv)) && throw(ArgumentError("Indices of NaNs in xv and yv must be the same"))

    nloop = count(nanix)

    edge = Vector{Tuple{Int,Int}}(undef, n)
    sizehint!(edge, nloop)

    iloop = 1
    start_idx = 1
    @inbounds for i in findall(nanix)
        end_idx = i - 1
        (xv[end_idx] ≈ xv[start_idx] && yv[end_idx] ≈ yv[start_idx]) && (end_idx -= 1)
        push!(edge, (start_idx, end_idx))
        start_idx = i + 1
        iloop += 1
    end

    if start_idx < n
        end_idx = n
        @inbounds (xv[n] ≈ xv[start_idx] && yv[n] ≈ yv[start_idx]) && (end_idx -= 1)
        push!(edge, (start_idx, end_idx))
    end
    edge
end