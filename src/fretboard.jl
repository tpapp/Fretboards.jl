struct FretBoard
    "Tuning of strings, from lowest to highest."
    tuning::Vector{Note}
    "Number of frets to display."
    frets::Int
end

const STANDARD_TUNING = [note"E2", note"A2", note"D3", note"G3", note"B3", note"E4"]

fret_position(semitones::Integer) = 1 - 0.5^(semitones / 12)
