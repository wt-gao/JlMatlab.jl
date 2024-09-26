module JlMatlab

export ndgrid, meshgrid

# `ndgrid` and `meshgrid` function
include("grid.jl")

"""
    JlMatlab.Geometry
Some utility functions for geometry
"""
module Geometry
include("geo.jl")
end

end # module JlMatlab
