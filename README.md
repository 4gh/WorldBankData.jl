World Bank Data in Julia
========================

The World Bank provides free access to data about development at
[data.worldbank.org](http://data.worldbank.org).

The primary collection of development indicators is called World
Development Indicators (WDI).

This module provides two functions to access and download the data:
`search_wdi()` and `wdi()`.

It follows roughly the
[R WDI package](http://cran.r-project.org/web/packages/WDI/index.html).

## Installation

```julia
using Pkg
Pkg.add("WorldBankData")
```

## Basic Examples

Obtain a DataFrame with the gross national income per capita for the
US and Brazil:

```julia
using WorldBankData
df=wdi("NY.GNP.PCAP.CD", ["US","BR"])
```

The WDI indicator `NY.GNP.PCAP.CD` becomes the symbol `NY_GNP_PCAP_CD` in the
DataFrame, i.e. `.` gets replaced by `_`.

### Multiple countries and indicators

```julia
using WorldBankData
df=wdi(["NY.GNP.PCAP.CD","AG.LND.ARBL.HA.PC"], ["US","BR"], startyear=1980, endyear=2008, extra=true)
```

This returns the GNI per capita and the arable land (hectares per
person) for the time range 1980-2008 for the US and Brazil. It also
attaches extra country information (the `extra=true` argument) like the
capital, longitude, latitude, income range, etc.

## Arguments

The `wdi` function has the following arguments:

```julia
wdi(indicators::Union{String,Array{String,1}}, countries::Union{String,Array{String,1}}, startyear::Integer=1800, endyear::Integer=3000; extra::Bool=false, verbose::Bool=false)
```

It needs a minimum of two arguments: the `indicators` (from the WDI
database) and the `countries` (ISO two letter country codes). The rest
are optional arguments.

`startyear`: First year to include.

`endyear`: Last year to include.

`extra`: If `extra=true`, `wdi()` attaches extra country data (like the
capital) to the returned DataFrame.

`verbose`: If `verbose=true`, `wdi()` will print URL download information. This
can be used as a progress indicator if many countries and indicators are
requested.

## Searching

The most convenient way to explore the database is probably through a
web browser at [data.worldbank.org](http://data.worldbank.org).

However, the module does provide a search function: `search_wdi()`.

One can search for "countries" or "indicators" data.

### Example for country search by name

```julia
julia> using WorldBankData
julia> res=search_wdi("countries","name",r"united"i)
julia> res[:name]
3-element DataArray{UTF8String,1}:
 "United Arab Emirates"
 "United Kingdom"
 "United States"
julia> res[:iso2c]
3-element DataArray{ASCIIString,1}:
 "AE"
 "GB"
 "US"
```

### Example for indicator search by description

```julia
julia> using WorldBankData
julia> res=search_wdi("indicators","description",r"gross national expenditure"i)
6x5 DataFrame
|-------|---------------------|------------|---------|
| Col # | Name                | Type       | Missing |
| 1     | description         | UTF8String | 0       |
| 2     | indicator           | UTF8String | 0       |
| 3     | name                | UTF8String | 0       |
| 4     | source_database     | UTF8String | 0       |
| 5     | source_organization | UTF8String | 0       |

julia> res[:name]
6-element DataArray{UTF8String,1}:
 "Gross national expenditure deflator (base year varies by country)"
 "Gross national expenditure (current US\$)"
 "Gross national expenditure (current LCU)"
 "Gross national expenditure (constant 2005 US\$)"
 "Gross national expenditure (constant LCU)"
 "Gross national expenditure (% of GDP)"

julia> res[:indicator]
6-element DataArray{UTF8String,1}:
 "NE.DAB.DEFL.ZS"
 "NE.DAB.TOTL.CD"
 "NE.DAB.TOTL.CN"
 "NE.DAB.TOTL.KD"
 "NE.DAB.TOTL.KN"
 "NE.DAB.TOTL.ZS"
```

### The search_wdi() function

The `search_wdi()` function has the following arguments
```julia
search_wdi(data::String, entry::String, regx::Regex)::DataFrame
```

`data`: Either `countries` or `indicators`.

`entry`: One of the attributes (like name).

`regex`: Regular expression to search for.

"countries" can be searched for "name", "region", "capital", "iso2c",
"iso3c", "income", and "lending".

"indicators" can be searched for "name", "description", "topics",
"source_database", and "source_organization".

The search function uses two DataFrames `country_cache` and
`indicator_cache` and searches through these. On the first search it
will download the data from the World Bank website. This takes much
longer for the larger indicators data. This only happens once per
session. After the first use the data is cached.

Note that the last argument to `search_wdi()` is a regular expression
denoted by `r"..."` and an `i` at the end means that it is case
insensitive.

### Examples of country searches

```julia
julia> search_wdi("countries","iso2c",r"TZ"i)
1x9 DataFrame
|-------|---------|------------|-------|-------|----------|---------|-----------|----------|----------------------------------------|
| Row # | capital | income     | iso2c | iso3c | latitude | lending | longitude | name     | region                                 |
| 1     | Dodoma  | Low income | TZ    | TZA   | -6.17486 | IDA     | 35.7382   | Tanzania | Sub-Saharan Africa (all income levels) |


julia> search_wdi("countries","income",r"upper middle"i)
...

julia> search_wdi("countries","region",r"Latin America"i)
...

julia> search_wdi("countries","capital",r"^Ka"i)
3x9 DataFrame
|-------|-----------|------------|-------|-------|----------|---------|-----------|-------------|----------------------------------------|
| Row # | capital   | income     | iso2c | iso3c | latitude | lending | longitude | name        | region                                 |
| 1     | Kabul     | Low income | AF    | AFG   | 34.5228  | IDA     | 69.1761   | Afghanistan | South Asia                             |
| 2     | Kathmandu | Low income | NP    | NPL   | 27.6939  | IDA     | 85.3157   | Nepal       | South Asia                             |
| 3     | Kampala   | Low income | UG    | UGA   | 0.314269 | IDA     | 32.5729   | Uganda      | Sub-Saharan Africa (all income levels) |

julia> search_wdi("countries","lending",r"IBRD"i)
...

```

### Examples of indicator searches

```julia
julia> search_wdi("indicators","name",r"gross national expenditure"i)
...
julia> search_wdi("indicators","description",r"gross national expenditure"i)
...
julia> search_wdi("indicators","source_database",r"Sustainable"i)
...
julia> search_wdi("indicators","source_organization",r"Global Partnership"i)

```

## Tips and Tricks

### Extracting country data from results

```julia
df=wdi("NY.GNP.PCAP.CD", ["US","BR"], 1980, 2012, extra=true)
us_gnp=df[df[:iso2c] .== "US",:]
```

### Year format

For similarity with the
[R WDI package](http://cran.r-project.org/web/packages/WDI/index.html) the `:year`
column is in Float64 format. WDI data is yearly.

You can easily convert this to a Date series:
```julia
using WorldBankData
using Dates

df=wdi("AG.LND.ARBL.HA.PC", "US", 1900, 2011)
df[:year] = map(Date, df[:year])
```

### Plotting

Install the [Plots.jl](https://github.com/JuliaPlots/Plots.jl) package with
`Pkg.add("Plots")`.

```julia
using WorldBankData
using Plots

df=wdi("AG.LND.ARBL.HA.PC", "US", 1980, 2010)

plot(df[:year], df[:AG_LND_ARBL_HA_PC])
```

### Empty/Missing results

`wdi` will return an empty DataFrame without warning if there is no data:
```julia
julia> dfAS=wdi("EN.ATM.CO2E.KT", "AS")
0x4 DataFrame
```

You can check for this with `size(dfAS)[1]==0`.

It will return a DataFrame for the cases where it has data, i.e.

```julia
julia> df=wdi("EN.ATM.CO2E.KT", ["AS","US"])
51x4 DataFrame
...
```

### Cache

The data in the World Bank database changes infrequently. Therefore it
makes little sense to download it every time a script is run.

#### Metadata

The `search_wdi()` function internally caches the country and
indicator metadata and therefore downloads the country and indicator
data only once per session. Even that is usually not necessary. This
data can easily be stored on local disk.

Download and store the country and indicator information in csv files:

```julia
using WorldBankData
using DataFrames
using CSV
CSV.write("country_cache.csv",WorldBankData.get_countries())
CSV.write("indicator_cache.csv", WorldBankData.get_indicators())
```

These can be used in the script to set the WorldBankData cache
variables `WorldBankData.country_cache` and
`WorldBankData.indicator_cache` (which are initialized to `false`)
using the `WorldBankData.set_country_cache()` and
`WorldBankData.set_indicator_cache()` functions:

```julia
using WorldBankData
using DataFrames
WorldBankData.set_country_cache(CSV.read("country_cache.csv"))
WorldBankData.set_indicator_cache(CSV.read("indicator_cache.csv"))
```
From then on the `search_wdi()` function will use the data read from
disk.

The caches can be reset with `WorldBankData.reset_country_cache()`
and `WorldBankData.reset_indicator_cache()`.

#### Indicator data

In a similar way the indicator data itself can be cached.

```julia
using WorldBankData
using DataFrames
using CSV

function update_us_gnp_per_cap()
    df = wdi("NY.GNP.PCAP.CD", "US")
    CSV.write("us_gnp.csv",df)
end
df=CSV.read("us_gnp.csv")
```
one then runs the `update_us_gnp_per_cap()` function only when needed.

## Build Status

[![Build Status](https://travis-ci.org/4gh/WorldBankData.jl.png)](https://travis-ci.org/4gh/WorldBankData.jl)
