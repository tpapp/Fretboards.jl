module Fretboards

using ArgCheck: @argcheck
using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF
using UnPack: @unpack

include("notes.jl")
include("chords.jl")
include("fretboard.jl")

end # module
