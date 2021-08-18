export STANDARD_TUNING, Annotation, Fretboard, get_tuning, get_frets, annotate_matches!

"""
Standard tuning for 6-string guitar.
"""
const STANDARD_TUNING = [pitch"E4", pitch"B3", pitch"G3", pitch"D3", pitch"A2", pitch"E2"]

####
#### character-based fretboard drawing
####

struct Annotation
    "The string which appears when the fretboard is rendered. Preferably something short."
    mark::String
    "Style for the mark (when supported by the terminal)."
    crayon::Crayon
end

"""
    Annotation(mark::AbstractString, [crayon])

A string annotation, with an optional color or style using [Crayons.Crayon](@ref).
"""
Annotation(mark::AbstractString) = Annotation(String(mark), Crayon())

struct Fretboard <: AbstractMatrix{Vector{Annotation}}
    "Tuning of the strings (from highest pitch)"
    tuning::Vector{Pitch}
    "Number of frets"
    frets::Int
    "Canvas for the annotations"
    canvas::OffsetMatrix{Vector{Annotation}}
    @doc """
    $(SIGNATURES)

    Create a fretboard which can be annotated with strings, either by as an
    `AbstractMatrix`, or using [`annotate_matches!`](@ref) (recommended).
    """
    function Fretboard(tuning::Vector{Pitch}, frets::Int)
        @argcheck frets ≥ 1
        @argcheck !isempty(tuning)
        canvas = OffsetMatrix{Vector{Annotation}}(undef, axes(tuning, 1), 0:frets)
        for i in eachindex(canvas)
            canvas[i] = Annotation[]
        end
        new(tuning, frets, canvas)
    end
end

Base.axes(fretboard::Fretboard) = axes(fretboard.canvas)

function Base.getindex(fretboard::Fretboard, string::Int, fret::Int)
    getindex(fretboard.canvas, string, fret)
end

"""
$(SIGNATURES)

Return the number of frets.
"""
get_frets(fretboard::Fretboard) = fretboard.frets

"""
$(SIGNATURES)

Return the tuning.
"""
get_tuning(fretboard::Fretboard) = get_frets(fretboard.fretboard)

"""
$(SIGNATURES)

For each fret on each string, call `f` with a value that has the following properties:

- `string`: the string number, from highest pitch (1), eg `6` for `pitch"E2"`
- `open_pitch`: the pitch of the open string (eg `pitch"E2"`)
- `pitch`: pitch of the fret (eg `pitch"G2")
- `fret`: fret number, eg `3`.

`f` should return an [`Annotation`](@ref) or `nothing`.
"""
function annotate_matches!(f, fretboard::Fretboard; skip_duplicates = true)
    @unpack tuning, frets, canvas = fretboard
    for (string, open_pitch) in pairs(tuning)
        for fret in 0:frets
            annotation = f((string = string, open_pitch = open_pitch,
                            pitch = open_pitch + fret, fret = fret))
            if !isnothing(annotation)
                annotations = canvas[string, fret]
                if !skip_duplicates || !(annotation ∈ annotations)
                    push!(annotations, annotation)
                end
            end
        end
    end
    fretboard
end

"""
$(SIGNATURES)

Shorthand for inserting the same annotation when `predicate` returns `true`. See the other
method of `annotate_matches!` for details.

# Example

```julia
julia> using Fretboards, Fretboards.Intervals

julia> fb = Fretboard(STANDARD_TUNING, 7);

julia> let root = pitch"C"
           for (mark, semitones) in [("1", 0), ("3", M3), ("5", P5)]
               annotate_matches!(x -> x.pitch ≂ root + semitones, Annotation(mark), fb)
           end
       end

julia> fb
          0      1      2      3      4      5      6      7
E4       3|------|------|-----5|------|------|------|------|
B3        |-----1|------|------|------|-----3|------|------|
G3       5|------|------|------|------|-----1|------|------|
D3        |------|-----3|------|------|-----5|------|------|
A2        |------|------|-----1|------|------|------|-----3|
E2       3|------|------|-----5|------|------|------|------|
```
"""
function annotate_matches!(predicate, annotation::Annotation, fretboard::Fretboard; kwargs...)
    annotate_matches!(x -> predicate(x) ? annotation : nothing, fretboard; kwargs...)
end

"""
$(TYPEDEF)

Characters for drawing a [`Fretboard`](@ref).

# Fields

$(FIELDS)
"""
struct DrawingChars
    "Strings between frets."
    string_char::Char
    "Fret-string crossings."
    fret_char::Char
    "Nut (fret 0)."
    nut_char::Char
end

const UNICODE_CHARS = DrawingChars('─','┼','├')

const ASCII_CHARS = DrawingChars('-','|','|')

"""
$(SIGNATURES)

Text width of all the annotations for a fret, with `string_char`.
"""
function _textwidth_ascii_fret_annotations(string_char, annotations)
    isempty(annotations) && return 0
    annotations_width = sum(annotation -> textwidth(annotation.mark), annotations)
    length(annotations) * textwidth(string_char) + annotations_width
end

"""
$(SIGNATURES)

Print ASCII for a single fret annotation, for the space between frets.

# Arguments

- `io`: output
- `string_char`: character for depicting strings, eg `-`,
- `fret_spacing`: the number of characters between frets
- `annotations`: a vector of `Annotation`s
"""
function _print_ascii_fret_annotations(io::IO, string_char, fret_spacing, annotations)
    padding = fret_spacing - _textwidth_ascii_fret_annotations(string_char, annotations)
    @argcheck padding ≥ 0
    print(io, string_char^padding)
    for annotation in annotations
        print(io, string_char, annotation.crayon(annotation.mark))
    end
end

"""
$(SIGNATURES)

Print ASCII for all annotations for a string.

# Arguments

- `io`: output
- `drawing_chars`: character set for drawing
- `fret_spacing`: the number of characters between frets
- `open_pitch`: pitch of the open string (fret 0)
- `all_annotations`: a vector of `Vector{Annotation}`s
"""
function _print_ascii_all_annotations(io::IO, drawing_chars::DrawingChars, fret_spacing,
                                      open_pitch, all_annotations)
    @unpack string_char, fret_char, nut_char = drawing_chars
    print(io, rpad(string(open_pitch), 4, ' '))
    for (fret, annotations) in pairs(all_annotations)
        _print_ascii_fret_annotations(io, fret == 0 ? ' ' : string_char, fret_spacing,
                                      annotations)
        print(io, fret == 0 ? nut_char : fret_char)
    end
    println(io)
end

"""
$(SIGNATURES)

Print fret numbers.

# Arguments

- `io`: output
- `fret_spacing`: the number of characters between frets
- `frets`: the number of frets
"""
function _print_ascii_fret_numbers(io::IO, fret_spacing, frets)
    print(io, ' '^4)
    for fret in 0:frets
        print(io, lpad(string(fret), fret_spacing + 1, ' '))
    end
    println(io)
end

"""
$(SIGNATURES)

Print `fretboard` with the specified `drawing_chars` character set.
"""
function print_ascii(io::IO, fretboard::Fretboard,
                     drawing_chars::DrawingChars = ASCII_CHARS,
                     min_fret_spacing = 4)
    @unpack frets, tuning, canvas = fretboard
    @unpack string_char = drawing_chars
    fret_spacing = max(maximum(a -> _textwidth_ascii_fret_annotations(string_char, a), canvas),
                       min_fret_spacing)
    _print_ascii_fret_numbers(io, fret_spacing, frets)
    for (string, open_pitch) in pairs(tuning)
        _print_ascii_all_annotations(io, drawing_chars, fret_spacing, open_pitch,
                                     @view canvas[string, :])
    end
end

function Base.show(io::IO, fretboard::Fretboard)
    print_ascii(io, fretboard)
end

function Base.show(io::IO, ::MIME"text/plain", fretboard::Fretboard)
    print_ascii(io, fretboard)
end
