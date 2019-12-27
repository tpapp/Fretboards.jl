struct Fretboard
    "Tuning of strings, from lowest to highest."
    tuning::Vector{Note}
    "Number of frets to display."
    frets::Int
end

const STANDARD_TUNING = [note"E2", note"A2", note"D3", note"G3", note"B3", note"E4"]

fret_position(semitones::Integer) = 1 - 0.5^(semitones / 12)

####
#### character-based fretboard drawing
####

struct CharFretboardCanvas
    fretboard::Fretboard
    "Canvas for drawing. First axis: strings in the same order as the tuning."
    canvas::Matrix{Char}
    offset::Int
    spacing::Int
    legend::Vector{String}
end

function char_fretboard_canvas(fretboard::Fretboard;
                               padding_left = 2,
                               spacing = 6,
                               extra_string_left = spacing ÷ 2,
                               extra_string_right = extra_string_left)
    @unpack tuning, frets = fretboard
    open_strings = string.(tuning)
    string_start = maximum(length, open_strings) + padding_left
    offset = string_start + extra_string_left
    canvas = fill(' ', length(tuning),
                  offset + spacing * (frets - 1) + extra_string_right)
    for (i, open_string) in enumerate(open_strings)
        copyto!(@view(canvas[i, 1:length(open_string)]), open_string)
        canvas[i, string_start:end] .= '-'
        for j in 0:(frets - 1)
            canvas[i, offset + j * spacing] = '|'
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
