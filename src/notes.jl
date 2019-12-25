struct Note
    "Semitones relative to C₀."
    semitones::Int
end

Broadcast.broadcastable(note::Note) = Ref(note)

struct Semitones
    semitones::Int
end

Broadcast.broadcastable(semitones::Semitones) = Ref(semitones)

# FIXME hash equality

Base.:+(note::Note, semitones::Semitones) = Note(note.semitones + semitones.semitones)

Base.:-(note::Note, semitones::Semitones) = Note(note.semitones - semitones.semitones)

Base.:-(note1::Note, note2::Note) = Semitones(note1.semitones - note2.semitones)

≅(note1::Note, note2::Note) = mod(note1.semitones, 12) == mod(note2.semitones, 12)

const NOTE_NAMES = ["C", "C♯", "D", "D♯", "E", "F",
                    "F♯", "G", "G♯", "A", "A♯", "B"]

function Base.show(io::IO, note::Note)
    octave, rel_semitone = fldmod(note.semitones, 12)
    print(io, "note\"", NOTE_NAMES[rel_semitone + 1], octave, "\"")
end

const MAJOR_SCALE_SEMITONES = [0, 2, 4, 5, 7, 9, 11]

"""
$(SIGNATURES)

Parse a note in [scientific pitch notation](https://en.wikipedia.org/wiki/Scientific_pitch_notation), composed of

- an upper- or lowecase letter A-G for the note

- an optional accidental `b`, `#` (plain ascii), or `♭`, `♯` (proper Unicode accidentals),

- an optional octave number (`0` if omitted, can be negative)

Example arguments: "C#2", "D♭-2" `.
"""
function parse_note(str::AbstractString)
    m = match(r"^([a-gA-G])([b♭#♯]?)(-?[0-9]*)$", str)
    @argcheck m ≢ nothing "Could not parse $str as a valid note."
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
    Note(octave * 12 + rel_semitone)
end

macro note_str(str)
    parse_note(str)
end
