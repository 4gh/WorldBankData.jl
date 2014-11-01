module TestExampleDownload

using Base.Test
using WorldBankData
using DataFrames

# reset the country and indicator caches from search_wdi.jl tests
# otherwise downloads will fail since the data is not in the cache
WorldBankData.reset_country_cache()
WorldBankData.reset_indicator_cache()

refdf = readtable(joinpath(dirname(@__FILE__),"example_data.csv"))

# download example case from documentation and compare to csv file
# retry 5 times if no data
function try_download(cntr=5)
    dfweb = ""
    while cntr > 0
        dfweb = wdi(["NY.GNP.PCAP.CD","AG.LND.ARBL.HA.PC"], ["US","BR"], 1980, 2008, true)
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

# data contains NA which breaks == check
function rm_na(df)
    mval = -123456
    df[:NY_GNP_PCAP_CD]=array(df[:NY_GNP_PCAP_CD], mval)
    df[:AG_LND_ARBL_HA_PC]=array(df[:AG_LND_ARBL_HA_PC], mval)
end

dfweb = try_download()

@test dfweb[:year] == refdf[:year]

@test rm_na(dfweb) == rm_na(refdf)

end
