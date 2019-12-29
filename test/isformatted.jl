using Test
using WorldBankData
using DocumentFormat

@testset "formatting" begin

    @test DocumentFormat.isformatted("WorldBankData")

end
