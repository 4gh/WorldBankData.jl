using Test
using WorldBankData

@testset "check all countries" begin

    @test WorldBankData.download_countries(verbose=true)[!, :iso2c] == WorldBankData.all_countries

end
