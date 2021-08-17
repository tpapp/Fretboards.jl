export Pitch, Semitones, ≂, @pitch_str

"""
A pitch (pitch). It is recommended that the `pitch"..."` constructor is used, see
[`parse_pitch`](@ref).
"""
struct Pitch
    "Semitones relative to C₀."
    semitones::Int
end

Broadcast.broadcastable(pitch::Pitch) = Ref(pitch)

"""
Semitones (relative pitch). Used in calculations, `+` and `-` are supported.
"""
struct Semitones
    semitones::Int
end

Broadcast.broadcastable(semitones::Semitones) = Ref(semitones)

# FIXME hash equality

Base.:+(pitch::Pitch, semitones::Semitones) = Pitch(pitch.semitones + semitones.semitones)

Base.:-(pitch::Pitch, semitones::Semitones) = Pitch(pitch.semitones - semitones.semitones)

Base.:-(pitch1::Pitch, pitch2::Pitch) = Semitones(pitch1.semitones - pitch2.semitones)

"""
$(SIGNATURES)

Test if two pitchs *octave equivalent* (ie are separated by an integer number of octaves), ie
are in the same *pitch class*.
"""
≂(pitch1::Pitch, pitch2::Pitch) = mod(pitch1.semitones, 12) == mod(pitch2.semitones, 12)

const PITCH_NAMES = ["C", "C♯", "D", "D♯", "E", "F",
                    "F♯", "G", "G♯", "A", "A♯", "B"]

function Base.string(pitch::Pitch)
    octave, rel_semitone = fldmod(pitch.semitones, 12)
    PITCH_NAMES[rel_semitone + 1] * string(octave)
end

function Base.show(io::IO, pitch::Pitch)
    print(io, "pitch\"", string(pitch), "\"")
end

"""
Major scale in semitones. Used internally, for pitch parsing.
"""
const MAJOR_SCALE_SEMITONES = [0, 2, 4, 5, 7, 9, 11]

"""
$(SIGNATURES)

Parse a pitch in [scientific pitch
notation](https://en.wikipedia.org/wiki/Scientific_pitch_notation), composed of

- an upper- or lowecase letter A-G for the pitch

- an optional accidental `b`, `#` (plain ascii), or `♭`, `♯` (Unicode accidentals),

- an optional octave number (`0` if omitted, can be negative)

Example arguments: "C#2", "D♭-2" `.
"""
function parse_pitch(str::AbstractString)
    m = match(r"^([a-gA-G])([b♭#♯]?)(-?[0-9]*)$", str)
    @argcheck m ≢ nothing "Could not parse $str as a valid pitch."
    _semitone, _accidental, _octave = m.captures
    major_tone = uppercase(first(_semitone)) - 'C' + 1
    if major_tone < 1
        major_tone += 7
    end
    rel_semitone = MAJOR_SCALE_SEMITONES[major_tone]
    if !isempty(_accidental)
        accidental = first(_accidental)
        if accidental == '#' || accidental == '♯'
            rel_semitone += 1
        elseif accidental == 'b' || accidental == '♭'
            rel_semitone -= 1
        end
    end
    octave = isempty(_octave) ? 0 : parse(Int, _octave)
    Pitch(octave * 12 + rel_semitone)
end

"""
pitch"..."

Parse the argument string as a [`Pitch`](@ref), eg

```jldoctest
julia> pitch"C♭2"
pitch"B1"
```

See [`parse_pitch`](@ref) for a full description.
"""
macro pitch_str(str)
    parse_pitch(str)
end
