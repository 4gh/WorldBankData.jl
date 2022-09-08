module TestExampleDownloadLong

using CSV
using Test
using WorldBankData
using DataFrames

# reset the country and indicator caches from search_wdi.jl tests
# otherwise downloads will fail since the data is not in the cache
WorldBankData.reset_country_cache()
WorldBankData.reset_indicator_cache()

refdf = DataFrame(CSV.File(joinpath(dirname(@__FILE__), "example_data.csv")))
refdf = select!(refdf, [:iso2c, :country, :AG_SRF_TOTL_K2, :year, :AG_LND_FRST_K2])
refdf = DataFrames.stack(refdf, [:AG_SRF_TOTL_K2, :AG_LND_FRST_K2])
refdf[!, :variable] = map(x -> replace(String(x), "_" => "."), refdf[!, :variable])
rename!(refdf, Dict(:variable => :indicator))


"""Download data. Retry up to 5 times in case of failure."""
function try_download(cntr = 5)
    dfweb = ""
    while cntr > 0
        dfweb = wdi(
            ["AG.SRF.TOTL.K2", "AG.LND.FRST.K2"],
            ["US", "BR"],
            1990,
            2010,
            dflong = true,
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

@testset "example download (long format)" begin

    dfweb = try_download()

    @test sort!(dfweb) == sort!(refdf)

end

end
