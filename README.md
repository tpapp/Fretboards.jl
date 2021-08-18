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
<style>
html span.sgr1 {
    font-weight: bolder;
}

html span.sgr2 {
    font-weight: lighter;
}

html span.sgr3 {
    font-style: italic;
}

html span.sgr4 {
    text-decoration: underline;
}

html span.sgr7 {
    color: #fff;
    background-color: #222;
}

html.theme--documenter-dark span.sgr7 {
    color: #1f2424;
    background-color: #fff;
}

html span.sgr8,
html span.sgr8 span,
html span span.sgr8 {
    color: transparent;
}

html span.sgr9 {
    text-decoration: line-through;
}


html span.sgr30 {
    color: #111;
}

html span.sgr31 {
    color: #944;
}

html span.sgr32 {
    color: #073;
}

html span.sgr33 {
    color: #870;
}

html span.sgr34 {
    color: #15a;
}

html span.sgr35 {
    color: #94a;
}

html span.sgr36 {
    color: #08a;
}

html span.sgr37 {
    color: #ddd;
}

html span.sgr40 {
    background-color: #111;
}

html span.sgr41 {
    background-color: #944;
}

html span.sgr42 {
    background-color: #073;
}

html span.sgr43 {
    background-color: #870;
}

html span.sgr44 {
    background-color: #15a;
}

html span.sgr45 {
    background-color: #94a;
}

html span.sgr46 {
    background-color: #08a;
}

html span.sgr47 {
    background-color: #ddd;
}

html span.sgr90 {
    color: #888;
}

html span.sgr91 {
    color: #d57;
}

html span.sgr92 {
    color: #2a5;
}

html span.sgr93 {
    color: #d94;
}

html span.sgr94 {
    color: #08d;
}

html span.sgr95 {
    color: #b8d;
}

html span.sgr96 {
    color: #0bc;
}

html span.sgr97 {
    color: #eee;
}


html span.sgr100 {
    background-color: #888;
}

html span.sgr101 {
    background-color: #d57;
}

html span.sgr102 {
    background-color: #2a5;
}

html span.sgr103 {
    background-color: #d94;
}

html span.sgr104 {
    background-color: #08d;
}

html span.sgr105 {
    background-color: #b8d;
}

html span.sgr106 {
    background-color: #0bc;
}

html span.sgr107 {
    background-color: #eee;
}
</style>
<pre>        0    1    2    3    4    5    6    7    8    9   10   11   12
E4     <span class="sgr31">1</span>├────┼────┼────┼────┼───<span class="sgr33">4</span>┼────┼───<span class="sgr32">5</span>┼────┼────┼────┼────┼───<span class="sgr31">1</span>┼
B3     <span class="sgr32">5</span>├────┼────┼────┼────┼───<span class="sgr31">1</span>┼────┼────┼────┼────┼───<span class="sgr33">4</span>┼────┼───<span class="sgr32">5</span>┼
G3      ├────┼───<span class="sgr33">4</span>┼────┼───<span class="sgr32">5</span>┼────┼────┼────┼────┼───<span class="sgr31">1</span>┼────┼────┼────┼
D3      ├────┼───<span class="sgr31">1</span>┼────┼────┼────┼────┼───<span class="sgr33">4</span>┼────┼───<span class="sgr32">5</span>┼────┼────┼────┼
A2     <span class="sgr33">4</span>├────┼───<span class="sgr32">5</span>┼────┼────┼────┼────┼───<span class="sgr31">1</span>┼────┼────┼────┼────┼───<span class="sgr33">4</span>┼
E2     <span class="sgr31">1</span>├────┼────┼────┼────┼───<span class="sgr33">4</span>┼────┼───<span class="sgr32">5</span>┼────┼────┼────┼────┼───<span class="sgr31">1</span>┼
</pre>
