#####
##### chords an intervals
#####

export CHORD_MAJOR, CHORD_MINOR, CHORD_DIM, CHORD_AUG

"""
A *named interval*, characterized by semitones, contaning a (short) label.
"""
struct NamedInterval
    semitones::Semitones
    label::String
end

NamedInterval(semitones::Integer, label) = NamedInterval(Semitones(semitones), label)

####
#### some named intervals (not exported, but part of the API)
####

"Root (unison)."
const P1 = NamedInterval(0, "1")

"Minor 3rd."
const m3 = NamedInterval(3, "m3")

"Major 3rd."
const M3 = NamedInterval(4, "M3")

"Perfect 4th."
const P4 = NamedInterval(5, "4")

"Diminished 5th."
const d5 = NamedInterval(6, "d5")

"Perfect 5th."
const P5 = NamedInterval(7, "5")

"Perfect 5th."
const A5 = NamedInterval(8, "A5")

"Minor 7th."
const m7 = NamedInterval(10, "m7")

"Major 7th."
const M7 = NamedInterval(11, "M7")

####
#### some named chords (exported, part of the API)
####

"Major triad chord."
CHORD_MAJOR = [P1, M3, P5]

"Minor triad chord."
CHORD_MINOR = [P1, m3, P5]

"Diminished triad chord."
CHORD_DIM = [P1, m3, d5]

"Augmented triad chord."
CHORD_AUG = [P1, M3, A5]
