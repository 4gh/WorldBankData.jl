module TestWDIJSON

using Test
using WorldBankData
using DataFrames
using JSON

# http://api.worldbank.org/countries/US/indicators/NY.GNP.PCAP.CD?date=1990:1997&format=json
testjsonstr = "[{\"page\":1,\"pages\":1,\"per_page\":\"50\",\"total\":8},[{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"value\":\"31390\",\"decimal\":\"0\",\"date\":\"1997\"},{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"value\":\"30380\",\"decimal\":\"0\",\"date\":\"1996\"},{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"value\":\"29150\",\"decimal\":\"0\",\"date\":\"1995\"},{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"value\":\"27750\",\"decimal\":\"0\",\"date\":\"1994\"},{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"value\":\"26480\",\"decimal\":\"0\",\"date\":\"1993\"},{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"value\":\"25780\",\"decimal\":\"0\",\"date\":\"1992\"},{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"value\":\"24370\",\"decimal\":\"0\",\"date\":\"1991\"},{\"indicator\":{\"id\":\"NY.GNP.PCAP.CD\",\"value\":\"GNI per capita, Atlas method (current US\$)\"},\"country\":{\"id\":\"US\",\"value\":\"United States\"},\"value\":\"24150\",\"decimal\":\"0\",\"date\":\"1990\"}]]"

dfref = DataFrame(iso2c=["US" for _ in range(1, length=8)],
  country=["United States" for _ in range(1, length=8)],
  NY_GNP_PCAP_CD=[31390.0, 30380.0, 29150.0, 27750.0, 26480.0, 25780.0, 24370.0, 24150.0],
  year=[ 1997.0, 1996.0, 1995.0, 1994.0, 1993.0, 1992.0, 1991.0, 1990.0])

#│ Row │ iso2c │ country       │ NY_GNP_PCAP_CD │ year   │
#├─────┼───────┼───────────────┼────────────────┼────────┤
#│ 1   │ US    │ United States │ 31390.0        │ 1997.0 │
#│ 2   │ US    │ United States │ 30380.0        │ 1996.0 │
#│ 3   │ US    │ United States │ 29150.0        │ 1995.0 │
#│ 4   │ US    │ United States │ 27750.0        │ 1994.0 │
#│ 5   │ US    │ United States │ 26480.0        │ 1993.0 │
#│ 6   │ US    │ United States │ 25780.0        │ 1992.0 │
#│ 7   │ US    │ United States │ 24370.0        │ 1991.0 │
#│ 8   │ US    │ United States │ 24150.0        │ 1990.0 

testjson = JSON.parse(testjsonstr)[2]

df = WorldBankData.parse_wdi("NY.GNP.PCAP.CD", testjson, 1990, 1997)

@test df == dfref

end
