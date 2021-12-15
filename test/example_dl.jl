using CSV
using Test
using WorldBankData
using DataFrames

# reset the country and indicator caches from search_wdi.jl tests
# otherwise downloads will fail since the data is not in the cache
WorldBankData.reset_country_cache()
WorldBankData.reset_indicator_cache()

refdf = DataFrame(CSV.File(joinpath(dirname(@__FILE__), "example_data.csv")))

# the data gets frequently updated on the World Bank site
# use this function to update the example_data.csv file
function update_example_data()
    dfnref = wdi(
        ["NY.GNP.PCAP.CD", "AG.LND.ARBL.HA.PC"],
        ["US", "BR"],
        1980,
        2008,
        extra = true,
        verbose = true,
    )
    CSV.write(joinpath(dirname(@__FILE__), "example_data.csv"), dfnref)
end

# download example case from documentation and compare to csv file
# retry 5 times if no data
function try_download(cntr = 5)
    dfweb = ""
    while cntr > 0
        dfweb = wdi(
            ["NY.GNP.PCAP.CD", "AG.LND.ARBL.HA.PC"],
            ["US", "BR"],
            1980,
            2008,
            extra = true,
            verbose = true,
        )
        if size(dfweb)[1] != 0
            break
        end
        println("      retry download")
        cntr = cntr - 1
        if cntr == 0
            error("unable to download data")
        end
    end
    dfweb
end

dfweb = try_download()

@test dfweb[!, :year] == refdf[!, :year]
@test sort(names(dfweb)) == sort(names(refdf))
@test dfweb == select!(refdf, names(dfweb))
