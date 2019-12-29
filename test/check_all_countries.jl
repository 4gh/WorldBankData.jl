using Test
using WorldBankData

@testset "check all countries" begin

    # checks the iso 2-letter country codes for updates
    @test WorldBankData.download_countries(verbose=true)[!, :iso2c] == WorldBankData.all_countries

end
