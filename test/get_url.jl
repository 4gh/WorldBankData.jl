using Test
using WorldBankData

@test WorldBankData.get_url("SP.POP.TOTL", "US", 1900, 2018, 2, verbose = false) ==
      "https://api.worldbank.org/v2/countries/US/indicators/SP.POP.TOTL?format=json&per_page=25000&date=1900:2018&source=2"

@test WorldBankData.get_url("SP.POP.TOTL", ["BR", "US"], 2000, 2017, 2, verbose = false) ==
      "https://api.worldbank.org/v2/countries/BR;US/indicators/SP.POP.TOTL?format=json&per_page=25000&date=2000:2017&source=2"
