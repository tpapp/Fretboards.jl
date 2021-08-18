#####
##### generate the output in the README
#####

using Fretboards, Crayons, ANSIColoredPrinters
using Fretboards.Intervals

fb = Fretboard(STANDARD_TUNING, 12);
let root = pitch"E"
    for (mark, semitones, color) in [("1", 0, :red),
                                     ("4", P4, :yellow),
                                     ("5", P5, :green)]
        annotate_matches!(x -> x.pitch ≂ root + semitones,
                          Annotation(mark, Crayon(foreground = color)), fb)
    end
end
buf = IOBuffer()
Fretboards.print_ascii(buf, fb, Fretboards.UNICODE_CHARS)
show(stdout, MIME"text/html"(), HTMLPrinter(buf))
end
