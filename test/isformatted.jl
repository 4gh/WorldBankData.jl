using Test
using WorldBankData
using FilePaths
using DocumentFormat

@testset "formatting" begin

    @test DocumentFormat.isformatted(p".")

end
