module TestBadArguments

using Test
using WorldBankData

@testset "bad arguments" begin

    @test_throws ErrorException wdi("NY.GNP.PCAP.CD", "US", 2000, 1900)

end

end
