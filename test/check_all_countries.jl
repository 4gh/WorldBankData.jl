module TestCheckAllCountries

using Test
using WorldBankData

example_iso3c = [
    "ABW",
    "AFE",
    "AFG",
    "AFR",
    "AFW",
    "AGO",
    "ALB",
    "AND",
    "ARB",
    "ARE",
    "ARG",
    "ARM",
    "ASM",
    "ATG",
    "AUS",
    "AUT",
    "AZE",
    "BDI",
    "BEA",
    "BEC",
    "BEL",
    "BEN",
    "BFA",
    "BGD",
    "BGR",
    "BHI",
    "BHR",
    "BHS",
    "BIH",
    "BLA",
    "BLR",
    "BLZ",
    "BMN",
    "BMU",
    "BOL",
    "BRA",
    "BRB",
    "BRN",
    "BSS",
    "BTN",
    "BWA",
    "CAA",
    "CAF",
    "CAN",
    "CEA",
    "CEB",
    "CEU",
    "CHE",
    "CHI",
    "CHL",
    "CHN",
    "CIV",
    "CLA",
    "CME",
    "CMR",
    "COD",
    "COG",
    "COL",
    "COM",
    "CPV",
    "CRI",
    "CSA",
    "CSS",
    "CUB",
    "CUW",
    "CYM",
    "CYP",
    "CZE",
    "DEA",
    "DEC",
    "DEU",
    "DJI",
    "DLA",
    "DMA",
    "DMN",
    "DNK",
    "DNS",
    "DOM",
    "DSA",
    "DSF",
    "DSS",
    "DZA",
    "EAP",
    "EAR",
    "EAS",
    "ECA",
    "ECS",
    "ECU",
    "EGY",
    "EMU",
    "ERI",
    "ESP",
    "EST",
    "ETH",
    "EUU",
    "FCS",
    "FIN",
    "FJI",
    "FRA",
    "FRO",
    "FSM",
    "FXS",
    "GAB",
    "GBR",
    "GEO",
    "GHA",
    "GIB",
    "GIN",
    "GMB",
    "GNB",
    "GNQ",
    "GRC",
    "GRD",
    "GRL",
    "GTM",
    "GUM",
    "GUY",
    "HIC",
    "HKG",
    "HND",
    "HPC",
    "HRV",
    "HTI",
    "HUN",
    "IBB",
    "IBD",
    "IBT",
    "IDA",
    "IDB",
    "IDN",
    "IDX",
    "IMN",
    "IND",
    "INX",
    "IRL",
    "IRN",
    "IRQ",
    "ISL",
    "ISR",
    "ITA",
    "JAM",
    "JOR",
    "JPN",
    "KAZ",
    "KEN",
    "KGZ",
    "KHM",
    "KIR",
    "KNA",
    "KOR",
    "KWT",
    "LAC",
    "LAO",
    "LBN",
    "LBR",
    "LBY",
    "LCA",
    "LCN",
    "LDC",
    "LIC",
    "LIE",
    "LKA",
    "LMC",
    "LMY",
    "LSO",
    "LTE",
    "LTU",
    "LUX",
    "LVA",
    "MAC",
    "MAF",
    "MAR",
    "MCO",
    "MDA",
    "MDE",
    "MDG",
    "MDV",
    "MEA",
    "MEX",
    "MHL",
    "MIC",
    "MKD",
    "MLI",
    "MLT",
    "MMR",
    "MNA",
    "MNE",
    "MNG",
    "MNP",
    "MOZ",
    "MRT",
    "MUS",
    "MWI",
    "MYS",
    "NAC",
    "NAF",
    "NAM",
    "NCL",
    "NER",
    "NGA",
    "NIC",
    "NLD",
    "NOR",
    "NPL",
    "NRS",
    "NRU",
    "NXS",
    "NZL",
    "OED",
    "OMN",
    "OSS",
    "PAK",
    "PAN",
    "PER",
    "PHL",
    "PLW",
    "PNG",
    "POL",
    "PRE",
    "PRI",
    "PRK",
    "PRT",
    "PRY",
    "PSE",
    "PSS",
    "PST",
    "PYF",
    "QAT",
    "ROU",
    "RRS",
    "RUS",
    "RWA",
    "SAS",
    "SAU",
    "SDN",
    "SEN",
    "SGP",
    "SLB",
    "SLE",
    "SLV",
    "SMR",
    "SOM",
    "SRB",
    "SSA",
    "SSD",
    "SSF",
    "SST",
    "STP",
    "SUR",
    "SVK",
    "SVN",
    "SWE",
    "SWZ",
    "SXM",
    "SXZ",
    "SYC",
    "SYR",
    "TCA",
    "TCD",
    "TEA",
    "TEC",
    "TGO",
    "THA",
    "TJK",
    "TKM",
    "TLA",
    "TLS",
    "TMN",
    "TON",
    "TSA",
    "TSS",
    "TTO",
    "TUN",
    "TUR",
    "TUV",
    "TWN",
    "TZA",
    "UGA",
    "UKR",
    "UMC",
    "URY",
    "USA",
    "UZB",
    "VCT",
    "VEN",
    "VGB",
    "VIR",
    "VNM",
    "VUT",
    "WLD",
    "WSM",
    "XKX",
    "XZN",
    "YEM",
    "ZAF",
    "ZMB",
    "ZWE",
]

@testset "check all_countries matches" begin

    data_iso3c = WorldBankData.download_countries(verbose = true)[!, :iso3c]
    @test example_iso3c == data_iso3c

end

end
