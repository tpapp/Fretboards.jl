using FretBoards
using FretBoards: parse_note
using Test

@testset "note parsing and representation" begin
    maybe0 = ["", "0"]
    sharps = ["♯", "#"]
    flats = ["♭", "b"]

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
end
