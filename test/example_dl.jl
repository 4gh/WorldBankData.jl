module TestExampleDownload

# example_dl.jl downloads data from the world bank web site.
# The data gets revised occasionally which breaks the test.

using CSV
using Test
using WorldBankData
using DataFrames

# reset the country and indicator caches from search_wdi.jl tests
# otherwise downloads will fail since the data is not in the cache
WorldBankData.reset_country_cache()
WorldBankData.reset_indicator_cache()

refdf = DataFrame(CSV.File(joinpath(dirname(@__FILE__), "example_data.csv")))

"""Download data. Retry up to 5 times in case of failure."""
function try_download(cntr = 5)
    dfweb = ""
    while cntr > 0
        dfweb = wdi(
            ["AG.SRF.TOTL.K2", "AG.LND.FRST.K2"],
            ["US", "BR"],
            1990,
            2010,
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

@testset "example download (wide format)" begin

    dfweb = try_download()

    @test dfweb[!, :year] == refdf[!, :year]
    @test sort(names(dfweb)) == sort(names(refdf))
    @test dfweb == select!(refdf, names(dfweb))

end

end
