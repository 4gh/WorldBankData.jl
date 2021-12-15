using Test
using WorldBankData
using DataFrames
using JSON

# http://api.worldbank.org/v2/countries/US/indicators/NY.GNP.PCAP.CD?date=1990:1997&format=json
testjsonstr = "[{\"page\":1,\"pages\":1,\"per_page\":50,\"total\":8,\"sourceid\":\"2\",\"lastupdated\":\"2020-07-01\"},[{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"countryiso3code\":\"USA\",\"date\":\"1997\",\"value\":31270,\"unit\":\"\",\"obs_status\":\"\",\"decimal\":0},{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"countryiso3code\":\"USA\",\"date\":\"1996\",\"value\":30270,\"unit\":\"\",\"obs_status\":\"\",\"decimal\":0},{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"countryiso3code\":\"USA\",\"date\":\"1995\",\"value\":29040,\"unit\":\"\",\"obs_status\":\"\",\"decimal\":0},{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"countryiso3code\":\"USA\",\"date\":\"1994\",\"value\":27650,\"unit\":\"\",\"obs_status\":\"\",\"decimal\":0},{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"countryiso3code\":\"USA\",\"date\":\"1993\",\"value\":26390,\"unit\":\"\",\"obs_status\":\"\",\"decimal\":0},{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"countryiso3code\":\"USA\",\"date\":\"1992\",\"value\":25680,\"unit\":\"\",\"obs_status\":\"\",\"decimal\":0},{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"countryiso3code\":\"USA\",\"date\":\"1991\",\"value\":24270,\"unit\":\"\",\"obs_status\":\"\",\"decimal\":0},{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"countryiso3code\":\"USA\",\"date\":\"1990\",\"value\":24060,\"unit\":\"\",\"obs_status\":\"\",\"decimal\":0}]]"

dfref = DataFrame(
    iso2c = ["US" for _ in range(1, length = 8)],
    country = ["United States" for _ in range(1, length = 8)],
    year = [1997.0, 1996.0, 1995.0, 1994.0, 1993.0, 1992.0, 1991.0, 1990.0],
    NY_GNP_PCAP_CD = [
        31270.0,
        30270.0,
        29040.0,
        27650.0,
        26390.0,
        25680.0,
        24270.0,
        24060.0,
    ],
)

testjson = JSON.parse(testjsonstr)[2]

df = WorldBankData.parse_wdi(["NY.GNP.PCAP.CD"], testjson, 1990, 1997, false)

@test df[!, :year] == dfref[!, :year]
@test sort(names(df)) == sort(names(dfref))
@test df == dfref
