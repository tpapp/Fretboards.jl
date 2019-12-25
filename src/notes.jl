struct Note
    "Semitones relative to C₀."
    semitones::Int
end

struct Semitones
    semitones::Int
end

# FIXME hash equality

Base.:+(note::Note, semitones::Semitones) = Note(note.semitones + semitones.semitones)

Base.:-(note::Note, semitones::Semitones) = Note(note.semitones - semitones.semitones)

Base.:-(note1::Note, note2::Note) = Semitones(note1.semitones - note2.semitones)

≅(note1::Note, note2::Note) = mod(note1.semitones, 12) == mod(note2.semitones)

const NOTE_NAMES = ["C", "C♯", "D", "D♯", "E", "F",
                    "F♯", "G", "G♯", "A", "A♯", "B"]

function Base.show(io::IO, note::Note)
    octave, rel_semitone = fldmod(note.semitones)
    print(io, "note", NOTE_NAMES[rel_semitone], octave)
end

const LETTER_REL_SEMITONES = [0, 2, 4, 5, 7, 9, 11]

"""
$(SIGNATURES)

Parse a note in [scientific pitch notation](https://en.wikipedia.org/wiki/Scientific_pitch_notation), composed of

- an upper- or lowecase letter A-G for the note

- an optional accidental `b`, `#` (plain ascii), or `♭`, `♯` (proper Unicode accidentals),

- an optional octave number (`0` if omitted, can be negative)

Example arguments: "C#2", "D♭-2" `.
"""
function parse_note(str::AbstractString)
    m = match(r"([a-gA-G])([b#]?)(-?[0-9]*)", "C#12")
    @argcheck m ≢ nothing "Could not parse $str as a valid note."
    rel_semitone = LETTER_REL_SEMITONES[uppercase(first(m.captures[1])) - 'A']
    accidental = first(m.capturers[2])
    if accidental == '#' || accidental == '♯'
        rel_semitone += 1
    elseif accidental == 'b' || accidental == '♭'
        rel_semitone -= 1
    end
    octave = parse(Int, m.captures[3])
    Note(octave * 12 + rel_semitone)
end

macro note_str(str)
    parse_note(str)
end
