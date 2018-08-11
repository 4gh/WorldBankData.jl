"""
Provides two functions, [`search_wdi`](@ref) and [`wdi`](@ref), for searching and fetching World Development Indicators data from the World Bank.
"""
module WorldBankData

using HTTP
using JSON
using DataFrames

export wdi, search_wdi


function download_parse_json(url::String; verbose::Bool=false)
    if verbose
        println("download: ", url)
    end
    request = HTTP.get(url)
    if request.status != 200
        error("download failed")
    end
    JSON.parse(String(request.body))
end

# convert json from worldbank for an indicator to dataframe
function parse_indicator(json::Array{Any,1})::DataFrame
    indicator_val = String[]
    name_val = String[]
    description_val = String[]
    source_database_val = String[]
    source_organization_val = String[]

    for d in json[2]
        append!(indicator_val,[d["id"]])
        append!(name_val,[d["name"]])
        append!(description_val,[d["sourceNote"]])
        append!(source_database_val, [d["source"]["value"]])
        append!(source_organization_val, [d["sourceOrganization"]])
    end

    DataFrame(indicator = indicator_val, name = name_val,
              description = description_val, source_database = source_database_val,
              source_organization = source_organization_val)
end

function tofloat(f::AbstractString)::Union{Missing, Float64}
     try
         return parse(Float64, f)
     catch
         return missing
     end
end

function convert_a2f(x::Union{Array{String,1},Array{String,1}})::Array{Union{Missing, Float64}, 1}
    n = length(x)
    arr = zeros(Union{Missing, Float64}, n)
    for i in 1:n
        arr[i]=tofloat(x[i])
    end
    arr
end

# convert country json to DataFrame
function parse_country(json::Array{Any,1})::DataFrame
    iso3c_val = String[]
    iso2c_val = String[]
    name_val = String[]
    region_val = String[]
    capital_val = String[]
    longitude_val = String[]
    latitude_val = String[]
    income_val = String[]
    lending_val = String[]

    for d in json[2]
        append!(iso3c_val,[d["id"]])
        append!(iso2c_val,[d["iso2Code"]])
        append!(name_val,[d["name"]])
        append!(region_val,[d["region"]["value"]])
        append!(capital_val,[d["capitalCity"]])
        append!(longitude_val,[d["longitude"]])
        append!(latitude_val,[d["latitude"]])
        append!(income_val,[d["incomeLevel"]["value"]])
        append!(lending_val,[d["lendingType"]["value"]])
    end

    longitude_val = convert_a2f(longitude_val)
    latitude_val = convert_a2f(latitude_val)

    DataFrame(iso3c = iso3c_val, iso2c = iso2c_val, name = name_val,
              region = region_val, capital = capital_val, longitude = longitude_val,
              latitude = latitude_val, income = income_val, lending = lending_val)
end

function download_indicators(;verbose::Bool=false)::DataFrame
    dat = download_parse_json("http://api.worldbank.org/indicators?per_page=25000&format=json", verbose=verbose)

    parse_indicator(dat)
end

function download_countries(;verbose::Bool=false)::DataFrame
    dat = download_parse_json("http://api.worldbank.org/countries/all?per_page=25000&format=json", verbose=verbose)

    parse_country(dat)
end

country_cache = false
indicator_cache = false

function reset_country_cache()
    global country_cache = false
end

function reset_indicator_cache()
    global indicator_cache = false
end

function set_country_cache(df::AbstractDataFrame)
    global country_cache = df
end

function set_indicator_cache(df::AbstractDataFrame)
    global indicator_cache = df
end

function get_countries(;verbose::Bool=false)
    if country_cache == false
        set_country_cache(download_countries(verbose=verbose))
    end
    country_cache
end

function get_indicators(;verbose::Bool=false)
    if indicator_cache == false
        set_indicator_cache(download_indicators(verbose=verbose))
    end
    indicator_cache
end

# The "." character is illegal in symbol, but used a lot in WDI. replace by "_".
# example: NY.GNP.PCAP.CD becomes NY_GNP_PCAP_CD
function make_symbol(x::String)::Symbol
    Symbol(replace(x, "." => "_"))
end

# return boolean array of matching entries
regex_match(df::Array{String,1}, regex::Regex)::Array{Bool, 1} = map(x -> occursin(regex, x), df)

df_match(df::AbstractDataFrame, entry::String, regex::Regex)::DataFrame = df[regex_match(df[make_symbol(entry)], regex),:]

function country_match(entry::String,regex::Regex)::DataFrame
    df = get_countries()
    df_match(df, entry, regex)
end

function indicator_match(entry::String,regex::Regex)::DataFrame
    df = get_indicators()
    df_match(df,entry,regex)
end

function search_countries(entry::String,regx::Regex)::DataFrame
    entries = ["name","region","capital","iso2c","iso3c","income","lending"]
    if !(entry in entries)
        error("unsupported country entry: \"",entry,"\". supported are:\n",entries)
    end
    country_match(entry,regx)
end

function search_indicators(entry::String, regx::Regex)::DataFrame
    entries = ["name","description","topics","source_database","source_organization"]
    if !(entry in entries)
        error("unsupported indicator entry: \"",entry,"\". supported are\n",entries)
    end
    indicator_match(entry,regx)
end


"""
search_wdi(data::String, entry::String, regx::Regex)::DataFrame

Search World Development Indicators for countries or indicators.

https://datacatalog.worldbank.org/dataset/world-development-indicators

**Arguments**

* `data` : data to search for: "indicators" or "countries"
* `entry` : entry to lookup
  for countries: `name`,`region`,`capital`,`iso2c`,`iso3c`,`income`,`lending`
  for indicators: `name`, `description`, `topics`, `source_database`, `source_organization`
* `regex` : regular expression to find

# Examples
```julia
search_wdi("countries", "name", r"united"i)
search_wdi("indicators", "description", r"gross national"i)
```
"""
function search_wdi(data::String, entry::String, regx::Regex)::DataFrame
    if data == "countries"
        return search_countries(entry, regx)
    elseif data == "indicators"
        return search_indicators(entry, regx)
    else
        error("unsupported data source:", data, ". supported are: \"countries\" or \"indicators\"")
    end
end

function clean_entry(x::Union{AbstractString, Nothing})
    if typeof(x) == Nothing
        return "NA"
    else
        return x
    end
end

function clean_append!(vals::Union{Array{String,1},Array{String,1}}, val::Union{String,String, Nothing})
    append!(vals,[clean_entry(val)])
end

function parse_wdi(indicator::String, json::Array{Any,1}, startyear::Integer, endyear::Integer)::DataFrame
    country_id = String[]
    country_name = String[]
    value = String[]
    date = String[]

    for d in json
        clean_append!(country_id,d["country"]["id"])
        clean_append!(country_name,d["country"]["value"])
        clean_append!(value,d["value"])
        clean_append!(date,d["date"])
    end

    value = convert_a2f(value)
    date = convert_a2f(date)

    df = DataFrame(iso2c = country_id, country = country_name)
    df[make_symbol(indicator)] = value
    df[:year] = date

    dropmissing(df)

    checkyear(x) = (x >= startyear) & (x <= endyear)
    yind = map(checkyear,df[:year])
    df[yind, :]
end

function wdi_download(indicator::String, country::Union{String,Array{String,1}}, startyear::Integer, endyear::Integer; verbose::Bool=false)::DataFrame
    if typeof(country) == String
        url = string("http://api.worldbank.org/countries/", country, "/indicators/", indicator,
                  "?date=", startyear,":", endyear, "&per_page=25000", "&format=json")
        json = [download_parse_json(url, verbose=verbose)[2]]
    elseif typeof(country) == Array{String,1}
        json = Any[]
        for c in country
            url = string("http://api.worldbank.org/countries/", c, "/indicators/", indicator,
                         "?date=", startyear,":", endyear, "&per_page=25000", "&format=json")
            append!(json,[download_parse_json(url, verbose=verbose)[2];])
        end
    end

    parse_wdi(indicator, json, startyear, endyear)
end

all_countries = ["AW", "AF", "A9", "AO", "AL", "AD", "L5", "1A", "AE", "AR", "AM", "AS", "AG", "AU", "AT", "AZ", "BI", "B4", "B7", "BE", "BJ", "BF", "BD", "BG", "B1", "BH", "BS", "BA", "B2", "BY", "BZ", "B3", "BM", "BO", "BR", "BB", "BN", "B6", "BT", "BW", "C9", "CF", "CA", "C4", "B8", "C5", "CH", "JG", "CL", "CN", "CI", "C6", "C7", "CM", "CD", "CG", "CO", "KM", "CV", "CR", "C8", "S3", "CU", "CW", "KY", "CY", "CZ", "D4", "D7", "DE", "D8", "DJ", "D2", "DM", "D3", "D9", "DK", "N6", "DO", "D5", "F6", "D6", "6D", "DZ", "4E", "V2", "Z4", "7E", "Z7", "EC", "EG", "XC", "ER", "ES", "EE", "ET", "EU", "F1", "FI", "FJ", "FR", "FO", "FM", "6F", "GA", "GB", "GE", "GH", "GI", "GN", "GM", "GW", "GQ", "GR", "GD", "GL", "GT", "GU", "GY", "XD", "HK", "HN", "XE", "HR", "HT", "HU", "ZB", "XF", "ZT", "XG", "XH", "ID", "XI", "IM", "IN", "XY", "IE", "IR", "IQ", "IS", "IL", "IT", "JM", "JO", "JP", "KZ", "KE", "KG", "KH", "KI", "KN", "KR", "KW", "XJ", "LA", "LB", "LR", "LY", "LC", "ZJ", "L4", "XL", "XM", "LI", "LK", "XN", "XO", "LS", "V3", "LT", "LU", "LV", "MO", "MF", "MA", "L6", "MC", "MD", "M1", "MG", "MV", "ZQ", "MX", "MH", "XP", "MK", "ML", "MT", "MM", "XQ", "ME", "MN", "MP", "MZ", "MR", "MU", "MW", "MY", "XU", "M2", "NA", "NC", "NE", "NG", "NI", "NL", "6L", "NO", "NP", "6X", "NR", "6N", "NZ", "OE", "OM", "S4", "PK", "PA", "PE", "PH", "PW", "PG", "PL", "V1", "PR", "KP", "PT", "PY", "PS", "S2", "V4", "PF", "QA", "RO", "R6", "O6", "RU", "RW", "8S", "SA", "L7", "SD", "SN", "SG", "SB", "SL", "SV", "SM", "SO", "RS", "ZF", "SS", "ZG", "S1", "ST", "SR", "SK", "SI", "SE", "SZ", "SX", "A4", "SC", "SY", "TC", "TD", "T4", "T7", "TG", "TH", "TJ", "TM", "T2", "TL", "T3", "TO", "T5", "T6", "TT", "TN", "TR", "TV", "TW", "TZ", "UG", "UA", "XT", "UY", "US", "UZ", "VC", "VE", "VG", "VI", "VN", "VU", "1W", "WS", "XK", "A5", "YE", "ZA", "ZM", "ZW"]

"""
wdi(indicators::Union{String,Array{String,1}}, countries::Union{String,Array{String,1}}, startyear::Integer=1800, endyear::Integer=3000; extra::Bool=false, verbose::Bool=false)::DataFrame

Download data from World Development Indicators (WDI) Data Catalog of the World Bank.

https://datacatalog.worldbank.org/dataset/world-development-indicators

**Arguments**
`indicators` : indicator name or array of indicators
`countries` : string or string array of ISO 2 letter country codes or `all` for all countries.
`startyear` : first year to include
`endyear` : last year to include
`extra` : if `true` additional country data should be included (region, capital, longitude, latitude, income, lending)
`verbose` : if `true` print URLs downloaded, useful as progress indicator.

# Examples
```julia
df = wdi("NY.GNP.PCAP.CD", "US", 1980, 2012, extra=true)
df = wdi("NY.GNP.PCAP.CD", ["US","BR"], 1980, 2012, extra=true)
df = wdi(["NY.GNP.PCAP.CD", "AG.LND.ARBL.HA.PC"], ["US","BR"], 1980, 2012, extra=true)
```
"""
function wdi(indicators::Union{String,Array{String,1}}, countries::Union{String,Array{String,1}}, startyear::Integer=1800, endyear::Integer=3000; extra::Bool=false, verbose::Bool=false)::DataFrame
    if countries == "all"
        countries = all_countries
    end

    if typeof(countries) == String
        countries = [countries]
    end

    for c in countries
        if ! (c in all_countries)
            error("country ",c," not found")
        end
    end

    if ! (startyear < endyear)
        error("startyear has to be < endyear. startyear=",startyear,". endyear=",endyear)
    end

    if typeof(indicators) == String
        indicators=[indicators]
    end

    df = wdi_download(indicators[1], countries, startyear, endyear, verbose=verbose)

    if length(indicators) > 1
        for ind in indicators[2:length(indicators)]
            dfn = wdi_download(ind, countries, startyear, endyear, verbose=verbose)
            df = join(df, dfn, on = [x for x in filter(x -> !(x in map(make_symbol, indicators)), names(df))],
                               kind = :outer)
        end
    end

    if extra
        cntdat = get_countries(verbose=verbose)
        df = join(df,cntdat,on=:iso2c)
    end

    sort!(df, [order(:iso2c), order(:year)])

    df
end

end
