# Fretboards.jl

![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)
[![build](https://github.com/tpapp/Fretboards.jl/workflows/CI/badge.svg)](https://github.com/tpapp/Fretboards.jl/actions?query=workflow%3ACI)
[![codecov.io](http://codecov.io/github/tpapp/Fretboards.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/Fretboards.jl?branch=master)

Julia package for visualizing chords on the guitar fretboard.

## Example

Visualizing an *Esus4* chord.

```julia
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
```

![](example.svg)
