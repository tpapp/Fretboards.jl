using Fretboards
using Fretboards: parse_note
using Test

@testset "note parsing and representation" begin
    maybe0 = ["", "0"]
    sharps = ["♯", "#"]
    flats = ["♭", "b"]

    "All combinations of the first letter and vectors of strings."
    function all_combinations(letter::Char, other_options...)
        str = string(letter)
        mapfoldl(x -> x isa AbstractString ? [x] : x,
                 (x, y) -> vec(x .* permutedims(y)),
                 other_options;
                 init = [lowercase(str), uppercase(str)])
    end

    @test all(parse_note.(all_combinations('c', maybe0)) .== Note(0))
    @test repr(Note(0)) == "note\"C0\""
    @test all(parse_note.(all_combinations('c', sharps, maybe0)) .== Note(1))
    @test repr(Note(1)) == "note\"C♯0\""
    @test all(parse_note.(all_combinations('c', flats, maybe0)) .== Note(-1))
    @test repr(Note(-1)) == "note\"B-1\""
    @test all(parse_note.(all_combinations('A', "2")) .== Note(24 + 9))
    @test repr(Note(24 + 9)) == "note\"A2\""
    @test all(parse_note.(all_combinations('A', flats, "2")) .== Note(24 + 8))
    @test repr(Note(24 + 8)) == "note\"G♯2\""
    @test all(parse_note.(all_combinations('A', sharps, "2")) .== Note(24 + 10))
    @test repr(Note(24 + 10)) == "note\"A♯2\""

    @test_throws ArgumentError parse_note("x")    # invalid note
    @test_throws ArgumentError parse_note("ax")   # trailing clutter
    @test_throws ArgumentError parse_note("a-1x") # trailing clutter
end

@testset "note calculations" begin
    @test Note(20) - Note(10) == Semitones(10)
    @test Note(20) - Note(10) == Semitones(10)
    @test Note(10) + Semitones(20) == Note(30)
    @test Note(10) - Semitones(20) == Note(-10)
    @test note"A♯" ≂ note"A♯-1" ≂ note"A♯2"
    @test !(note"C" ≂ note"D")
end

@testset "fretboard basics" begin
    @test fret_position(9) ≈ 0.405396 atol = 1e-5
    @test fret_position(12) == 0.5
    @test fret_position(19) ≈ 0.666290 atol = 1e-5
end
