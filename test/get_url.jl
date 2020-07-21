using Test
using WorldBankData

@test WorldBankData.get_url("SP.POP.TOTL", "US", 1900, 2018, verbose = false) == "https://api.worldbank.org/v2/countries/US/indicators/SP.POP.TOTL?format=json&per_page=25000&date=1900:2018"

@test WorldBankData.get_url("SP.POP.TOTL", ["BR", "US"], 2000, 2017, verbose = false) == "https://api.worldbank.org/v2/countries/BR;US/indicators/SP.POP.TOTL?format=json&per_page=25000&date=2000:2017"

