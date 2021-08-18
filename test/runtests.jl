using Fretboards
using Fretboards: parse_pitch
using Test

@testset "pitch parsing and representation" begin
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

    @test all(parse_pitch.(all_combinations('c', maybe0)) .== Pitch(0))
    @test repr(Pitch(0)) == "pitch\"C0\""
    @test all(parse_pitch.(all_combinations('c', sharps, maybe0)) .== Pitch(1))
    @test repr(Pitch(1)) == "pitch\"C♯0\""
    @test all(parse_pitch.(all_combinations('c', flats, maybe0)) .== Pitch(-1))
    @test repr(Pitch(-1)) == "pitch\"B-1\""
    @test all(parse_pitch.(all_combinations('A', "2")) .== Pitch(24 + 9))
    @test repr(Pitch(24 + 9)) == "pitch\"A2\""
    @test all(parse_pitch.(all_combinations('A', flats, "2")) .== Pitch(24 + 8))
    @test repr(Pitch(24 + 8)) == "pitch\"G♯2\""
    @test all(parse_pitch.(all_combinations('A', sharps, "2")) .== Pitch(24 + 10))
    @test repr(Pitch(24 + 10)) == "pitch\"A♯2\""

    @test_throws ArgumentError parse_pitch("x")    # invalid pitch
    @test_throws ArgumentError parse_pitch("ax")   # trailing clutter
    @test_throws ArgumentError parse_pitch("a-1x") # trailing clutter
end

@testset "pitch calculations" begin
    @test Pitch(20) - Pitch(10) == 10
    @test Pitch(20) - Pitch(10) == 10
    @test Pitch(10) + 20 == Pitch(30)
    @test Pitch(10) - 20 == Pitch(-10)
    @test pitch"A♯" ≂ pitch"A♯-1" ≂ pitch"A♯2"
    @test !(pitch"C" ≂ pitch"D")
end
