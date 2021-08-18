module Fretboards

using ArgCheck: @argcheck
using Crayons: Crayon
using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF
using OffsetArrays: OffsetMatrix
using UnPack: @unpack

include("pitch.jl")
include("fretboard.jl")

end # module
