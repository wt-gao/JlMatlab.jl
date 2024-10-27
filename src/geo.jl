"""
    inpolygon(
        xv::AbstractVector{<:Real}, yv::AbstractVector{<:Real},
        xq::AbstractVector{<:Real}, yq::AbstractVector{<:Real}
    ) -> Vector{Bool}
Test quiried points (`xq`,`yq`) if they are inside the polygon defined by (`xv`,`yv`).
`true` if inside, `false` otherwise.
"""
function inpolygon(
    xv::AbstractVector{<:Real}, yv::AbstractVector{<:Real},
    xq::AbstractVector{<:Real}, yq::AbstractVector{<:Real}
)
    length(xq) != length(yq) && throw(ArgumentError("xq and yq must have the same length"))

    p = (xv, yv)
    e = _poly_edge(p)
    _inpolygon(p, e, (xq, yq))
end

function _poly_edge(p)
    n = getn(p)
    nanix = [isnan(getx(p, i)) for i in 1:n]
    naniy = [isnan(gety(p, i)) for i in 1:n]
    any(nanix ⊻ naniy) && throw(ArgumentError(
        "Indices of NaNs in x coordinate and y coordinate must be the same"))

    e = Tuple{Int,Int}[]
    sizehint!(e, n)

    nanloc = (1:n)[nanix]
    push!(nanloc, n + 1)

    start_idx = 1
    @inbounds for i in nanloc
        end_idx = i - 1
        append!(e, [(j, j + 1) for j in start_idx:end_idx])
        isclosed(p, end_idx, start_idx) && (pop!(e); end_idx -= 1)
        e[end] = (end_idx, start_idx)
        start_idx = i + 1
    end
    e
end

const Point{T} = Tuple{T,T} where {T<:Real}
const Edge = Tuple{Int,Int}
const AbstractPolygon = AbstractVector{Point{<:Real}}

inpolygon(pv, pq) = (e = _poly_edge(pv); _inpolygon(pv, e, pq))
function inpolygon(pv::AbstractVector{<:AbstractVector{Point{T}}}, q) where {T<:Real}
    ns = map(length, pv)
    p = Point{T}[]

    np = sum(ns)
    sizehint!(p, np)

    e = Edge[]
    sizehint!(e, np)

    pcount = 0
    @inbounds for v in pv
        nv = getn(v)
        append!(p, v)
        append!(e, [(pcount + j, pcount + j + 1) for j in 1:nv])
        isclosed(v, nv, 1) && (pop!(e); nv -= 1)
        e[end] = (nv, 1)
        pcount += nv
    end
    _inpolygon(p, e, q)
end

function _orient(pa, pb, pc)
    d = (pb[1] - pa[1]) * (pc[2] - pa[2]) - (pc[1] - pa[1]) * (pb[2] - pa[2])
    d ≈ 0 && return 0
    d > 0 ? 1 : -1
end

function _inpolygon(p, e, q)
    n = getn(q)
    ixin = Vector{Bool}(undef, n)
    ixon = Vector{Bool}(undef, n)
    test_edge(i) = @inbounds begin
        D = 0
        for ej in e
            !(gety(p, ej[1]) > gety(q, i) ⊻ gety(p, ej[2]) > gety(q, i)) && continue
            d = _orient((getx(q, i), gety(q, i)),
                (getx(p, ej[1]), gety(p, ej[1])),
                (getx(p, ej[2]), gety(p, ej[2])))
            d == 0 && (ixin[i] = true; ixon[i] = true; return)
            D += d
        end
        ixin[i] = D != 0
        ixon[i] = false
        nothing
    end
    test_edge.(1:length(q))
    (ixin, ixon)
end

getx(p) = p[1]
gety(p) = p[2]

getx(p::AbstractVector{Point{<:Real}}, i::Integer) = (@inbounds p[Int(i)][1])
gety(p::AbstractVector{Point{<:Real}}, i::Integer) = (@inbounds p[Int(i)][2])

getx(p::AbstractMatrix{<:Real}, i::Integer) = (@inbounds p[Int(i), 1])
gety(p::AbstractMatrix{<:Real}, i::Integer) = (@inbounds p[Int(i), 2])

getx(p::Tuple{AbstractVector{<:Real},AbstractVector{<:Real}}, i::Integer) = (@inbounds p[1][Int(i)])
gety(p::Tuple{AbstractVector{<:Real},AbstractVector{<:Real}}, i::Integer) = (@inbounds p[2][Int(i)])

getn(p) = length(p)
getn(p::AbstractMatrix{<:Real}) = size(p, 1)
getn(p::Tuple{AbstractVector{<:Real},AbstractVector{<:Real}}) = length(p[1])

isclosed(p, i::Integer, j::Integer) = getx(p, i) ≈ getx(p, j) && gety(p, i) ≈ gety(p, j)