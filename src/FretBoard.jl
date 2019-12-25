module FretBoard

export Note, Semitones, ≅,  note_str

using PGFPlotsX
using ArgCheck: @argcheck
using DocStringExtensions: SIGNATURES
using UnPack: @unpack

include("notes.jl")

end # module
