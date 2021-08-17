export Fretboard, get_tuning, get_frets, STANDARD_TUNING, OPEN_D_TUNING, fret_position,
    char_fretboard_canvas, annotate_fret!, annotate_matches!, AnnotatePitchClass,
    annotate_chord!

"""
Abstract description of a fretboard.

# Fields

$(FIELDS)
"""
struct Fretboard
    "Tuning of strings, from lowest to highest."
    tuning::Vector{Pitch}
    "Number of frets."
    frets::Int
end

"""
$(SIGNATURES)

Return the number of frets (indexing for which starts at `0`).
"""
get_frets(fretboard::Fretboard) = fretboard.frets

"""
$(SIGNATURES)

Return the tuning, as a vector of `Pitch`s.
"""
get_tuning(fretboard::Fretboard) = fretboard.tuning

"""
Standard tuning for 6-string guitar.
"""
const STANDARD_TUNING = [pitch"E2", pitch"A2", pitch"D3", pitch"G3", pitch"B3", pitch"E4"]

"""
Open D tuning for 6-string guitar.
"""
const OPEN_D_TUNING = [pitch"D2", pitch"A2", pitch"D3", pitch"F♯3", pitch"A3", pitch"D4"]

"""
Abstract type for fretboard canvases, used only for code organization, not part of the API.
"""
abstract type FretboardCanvas end

get_frets(fbc::FretboardCanvas) = get_frets(fbc.fretboard)

get_tuning(fbc::FretboardCanvas) = get_tuning(fbc.fretboard)

####
#### character-based fretboard drawing
####

"""
$(TYPEDEF)

Character-based canvas for drawing fretboards.
"""
struct CharFretboardCanvas <: FretboardCanvas
    "The underlying fretboard."
    fretboard::Fretboard
    """
    Canvas for drawing (a matrix of characters).

    First axis: strings in the same order as the tuning.

    Second axis: characters. Use various annotation functions to overwrite.
    """
    canvas::Matrix{Char}
    "Character for first fret."
    offset::Int
    "Spacing between frets."
    spacing::Int
    "Additional legend strings that can be added."
    legend::Vector{String}
end

"""
$(TYPEDEF)

Characters for drawing a [`CharFretboarCanvas`](@ref).

# Fields

$(FIELDS)
"""
struct DrawingChars
    "For drawing strings between frets."
    string::Char
    "For drawing fret-string crossings."
    fret::Char
end

const UNICODE_CHARS = DrawingChars('─','┼')

const ASCII_CHARS = DrawingChars('-', '|')

"""
$(SIGNATURES)

Make a blank fretboard canvas from a `fretboard`.
"""
function char_fretboard_canvas(fretboard::Fretboard;
                               spacing = 6,
                               padding_left = max(spacing ÷ 2, 3),
                               extra_string_left = 0,
                               extra_string_right = spacing ÷ 2,
                               drawing_chars = ASCII_CHARS)
    @unpack tuning, frets = fretboard
    open_strings = string.(tuning)
    string_start = maximum(length, open_strings) + padding_left + 1
    offset = string_start + extra_string_left
    canvas = fill(' ', length(tuning),
                  offset + spacing * frets + extra_string_right)
    for (i, open_string) in enumerate(open_strings)
        copyto!(@view(canvas[i, 1:length(open_string)]), open_string)
        canvas[i, string_start:end] .= drawing_chars.string
        for j in 0:frets
            canvas[i, offset + j * spacing] = drawing_chars.fret
        end
    end
    CharFretboardCanvas(fretboard, canvas, offset, spacing, String[])
end

function Base.show(io::IO, fretboard_canvas::CharFretboardCanvas)
    @unpack canvas, legend = fretboard_canvas
    for i in reverse(axes(canvas, 1))
        for j in axes(canvas, 2)
            print(io, canvas[i, j])
        end
        println(io)
    end
    for l in legend
        println(io, legend)
    end
end

function _annotate_fret!(canvas_line::AbstractVector, fretboard_canvas, fret::Integer,
                         text::AbstractString)
    @unpack offset, spacing, fretboard = fretboard_canvas
    @argcheck 0 ≤ fret ≤ fretboard.frets
    fret_char = offset + spacing * fret
    annotation_offset = fret_char - length(text) ÷ 2 - 1
    for (i, c) in enumerate(text)
        canvas_line[annotation_offset + i] = c
    end
    nothing
end

function annotate_fret!(fretboard_canvas::CharFretboardCanvas, string::Integer,
                        fret::Integer, text::AbstractString)
    _annotate_fret!(@view(fretboard_canvas.canvas[string, :]), fretboard_canvas, fret, text)
end

function annotate_matches!(f, fretboard_canvas::CharFretboardCanvas)
    for (string, open_pitch) in enumerate(get_tuning(fretboard_canvas))
        for fret in 0:get_frets(fretboard_canvas)
            annotation = f(string, open_pitch, open_pitch + Semitones(fret))
            if !isnothing(annotation)
                annotate_fret!(fretboard_canvas, string, fret, annotation)
            end
        end
    end
    fretboard_canvas
end

struct AnnotatePitchClass{T}
    pitch::Pitch
    annotation::T
end

(a::AnnotatePitchClass)(_, _, pitch) = a.pitch ≂ pitch ? a.annotation : nothing

function annotate_chord!(fretboard_canvas::CharFretboardCanvas, base_pitch, chord)
    for interval in chord
        annotate_matches!(AnnotatePitchClass(base_pitch + interval.semitones,
                                             "(" * interval.label * ")"),
                          fretboard_canvas)
    end
    fretboard_canvas
end

####
#### graphical fretboard drawing (WIP)
####

"""
$(SIGNATURES)

Fret position from the 0th fret, as a fraction of the whole string length.
"""
fret_position(semitones::Integer) = 1 - 0.5^(semitones / 12)
