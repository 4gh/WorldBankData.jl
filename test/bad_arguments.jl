using Test
using WorldBankData

@test_throws ErrorException wdi("NY.GNP.PCAP.CD", "US", 2000, 1900)
