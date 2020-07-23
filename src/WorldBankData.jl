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
        append!(indicator_val, [d["id"]])
        append!(name_val, [d["name"]])
        append!(description_val, [d["sourceNote"]])
        append!(source_database_val, [d["source"]["value"]])
        append!(source_organization_val, [d["sourceOrganization"]])
    end

    DataFrame(indicator=indicator_val, name=name_val,
              description=description_val, source_database=source_database_val,
              source_organization=source_organization_val)
end

function tofloat(f::AbstractString)::Union{Missing,Float64}
    x = tryparse(Float64, f)
    x isa Nothing ? missing : x
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
        append!(iso3c_val, [d["id"]])
        append!(iso2c_val, [d["iso2Code"]])
        append!(name_val, [d["name"]])
        append!(region_val, [d["region"]["value"]])
        append!(capital_val, [d["capitalCity"]])
        append!(longitude_val, [d["longitude"]])
        append!(latitude_val, [d["latitude"]])
        append!(income_val, [d["incomeLevel"]["value"]])
        append!(lending_val, [d["lendingType"]["value"]])
    end

    longitude_val = tofloat.(longitude_val)
    latitude_val = tofloat.(latitude_val)

    DataFrame(iso3c=iso3c_val, iso2c=iso2c_val, name=name_val,
              region=region_val, capital=capital_val, longitude=longitude_val,
              latitude=latitude_val, income=income_val, lending=lending_val)
end

function download_indicators(;verbose::Bool=false)::DataFrame
    dat = download_parse_json("https://api.worldbank.org/v2/indicators?per_page=25000&format=json", verbose=verbose)

    parse_indicator(dat)
end

function download_countries(;verbose::Bool=false)::DataFrame
    dat = download_parse_json("https://api.worldbank.org/v2/countries/all?per_page=25000&format=json", verbose=verbose)

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

make_symbol(x::Symbol) = x

df_match(df::AbstractDataFrame, entry::String, regex::Regex)::DataFrame = df[occursin.(Ref(regex), df[!, make_symbol(entry)]),:]

function country_match(entry::String, regex::Regex)::DataFrame
    df = get_countries()
    df_match(df, entry, regex)
end

function indicator_match(entry::String, regex::Regex)::DataFrame
    df = get_indicators()
    df_match(df, entry, regex)
end

function search_countries(entry::String, regx::Regex)::DataFrame
    entries = ["name","region","capital","iso2c","iso3c","income","lending"]
    if !(entry in entries)
        error("unsupported country entry: \"", entry, "\". supported are:\n", entries)
    end
    country_match(entry, regx)
end

function search_indicators(entry::String, regx::Regex)::DataFrame
    entries = ["name","description","topics","source_database","source_organization"]
    if !(entry in entries)
        error("unsupported indicator entry: \"", entry, "\". supported are\n", entries)
    end
    indicator_match(entry, regx)
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

function clean_entry(x::Union{AbstractString,Nothing})
    if typeof(x) == Nothing
        return "NA"
    else
        return x
    end
end

function clean_append!(vals::Union{Array{String,1},Array{String,1}}, val::Union{String,String,Nothing})
    append!(vals, [clean_entry(val)])
end

function parse_wdi(indicators::Array{String,1}, jsondata::Array{Any,1}, startyear::Integer, endyear::Integer, returnlong::Bool)::DataFrame
    country_id = String[]
    country_name = String[]
    value = Union{Float64,Missing}[]
    date = String[]
    indicator_id = String[]

    for d in jsondata
        clean_append!(country_id, d["country"]["id"])
        clean_append!(country_name, d["country"]["value"])
        clean_append!(indicator_id, d["indicator"]["id"])
        push!(value, d["value"] isa Nothing ? missing : d["value"])
        clean_append!(date, d["date"])
    end

    date = tofloat.(date)

    dflong = DataFrame(iso2c=country_id, country=country_name, year=date, indicator=indicator_id, value=value)

    if returnlong
        return dflong
    end

    dflong[!,:indicator] = map(x -> replace(x, "." => "_"), dflong[!,:indicator])
    noindcols = filter(x -> (x != "indicator") && (x != "value"), names(dflong))
    dfwide = unstack(dflong, noindcols, :indicator, :value)

    dfwide
end

function array_to_querystr(values::Array{String,1})::String
    res = ""
    for (i, v) in enumerate(values)
        if i == 1
            res = v
        else
            res = string(res, ";", v)
        end
    end
    res
end

function get_url(indicators::Union{String,Array{String,1}}, countries::Union{String,Array{String,1}}, startyear::Integer, endyear::Integer, sourceid::Integer; verbose::Bool=false)::String
    datestr = ""
    if startyear == -1 && endyear == -1
        datestr = ""
    elseif startyear == -1 && endyear != -1
        datestr = string("&date=1800:", endyear)
    elseif startyear != -1 && endyear == -1
        error("need to also set endyear if startyear is given")
    elseif startyear != -1 && endyear != -1
        datestr = string("&date=", startyear, ":", endyear)
    else
        error("internal error. should never get here")
    end

    countriesstr = ""
    if typeof(countries) == String
        countriesstr = countries
    elseif typeof(countries) == Array{String,1}
        countriesstr = array_to_querystr(countries)
    end

    indicatorstr = ""
    if typeof(indicators) == String
        indicatorstr = indicators
    elseif typeof(indicators) == Array{String,1}
        indicatorstr = array_to_querystr(indicators)
    end

    url = string("https://api.worldbank.org/v2/countries/", countriesstr, "/indicators/", indicatorstr,
                 "?format=json&per_page=25000", datestr, "&source=", sourceid)

    url
end

function wdi_download(indicators::Union{String,Array{String,1}}, countries::Union{String,Array{String,1}}, startyear::Integer, endyear::Integer, sourceid::Integer, dflong::Bool; verbose::Bool=false)::DataFrame
    url = get_url(indicators, countries, startyear, endyear, sourceid, verbose=verbose)
    jsondata = download_parse_json(url, verbose=verbose)

    if length(jsondata) == 1
        d = jsondata[1]
        if haskey(d, "message")
            msg = d["message"][1]
            error("request error. response key=\"", msg["key"], "\". value=\"", msg["value"], "\"")
        end
        error("response json data problem:", jsondata)
    end

    if length(jsondata) != 2
        error("wrong length json reply:", jsondata)
    end

    parse_wdi(indicators, jsondata[2], startyear, endyear, dflong)
end

all_countries = ["AW", "AF", "A9", "AO", "AL", "AD", "L5", "1A", "AE", "AR", "AM", "AS", "AG", "AU", "AT", "AZ", "BI", "B4", "B7", "BE", "BJ", "BF", "BD", "BG", "B1", "BH", "BS", "BA", "B2", "BY", "BZ", "B3", "BM", "BO", "BR", "BB", "BN", "B6", "BT", "BW", "C9", "CF", "CA", "C4", "B8", "C5", "CH", "JG", "CL", "CN", "CI", "C6", "C7", "CM", "CD", "CG", "CO", "KM", "CV", "CR", "C8", "S3", "CU", "CW", "KY", "CY", "CZ", "D4", "D7", "DE", "D8", "DJ", "D2", "DM", "D3", "D9", "DK", "N6", "DO", "D5", "F6", "D6", "6D", "DZ", "4E", "V2", "Z4", "7E", "Z7", "EC", "EG", "XC", "ER", "ES", "EE", "ET", "EU", "F1", "FI", "FJ", "FR", "FO", "FM", "6F", "GA", "GB", "GE", "GH", "GI", "GN", "GM", "GW", "GQ", "GR", "GD", "GL", "GT", "GU", "GY", "XD", "HK", "HN", "XE", "HR", "HT", "HU", "ZB", "XF", "ZT", "XG", "XH", "ID", "XI", "IM", "IN", "XY", "IE", "IR", "IQ", "IS", "IL", "IT", "JM", "JO", "JP", "KZ", "KE", "KG", "KH", "KI", "KN", "KR", "KW", "XJ", "LA", "LB", "LR", "LY", "LC", "ZJ", "L4", "XL", "XM", "LI", "LK", "XN", "XO", "LS", "V3", "LT", "LU", "LV", "MO", "MF", "MA", "L6", "MC", "MD", "M1", "MG", "MV", "ZQ", "MX", "MH", "XP", "MK", "ML", "MT", "MM", "XQ", "ME", "MN", "MP", "MZ", "MR", "MU", "MW", "MY", "XU", "M2", "NA", "NC", "NE", "NG", "NI", "NL", "6L", "NO", "NP", "6X", "NR", "6N", "NZ", "OE", "OM", "S4", "PK", "PA", "PE", "PH", "PW", "PG", "PL", "V1", "PR", "KP", "PT", "PY", "PS", "S2", "V4", "PF", "QA", "RO", "R6", "O6", "RU", "RW", "8S", "SA", "L7", "SD", "SN", "SG", "SB", "SL", "SV", "SM", "SO", "RS", "ZF", "SS", "ZG", "S1", "ST", "SR", "SK", "SI", "SE", "SZ", "SX", "A4", "SC", "SY", "TC", "TD", "T4", "T7", "TG", "TH", "TJ", "TM", "T2", "TL", "T3", "TO", "T5", "T6", "TT", "TN", "TR", "TV", "TW", "TZ", "UG", "UA", "XT", "UY", "US", "UZ", "VC", "VE", "VG", "VI", "VN", "VU", "1W", "WS", "XK", "A5", "YE", "ZA", "ZM", "ZW"]

"""
function wdi(indicators::Union{String,Array{String,1}}, countries::Union{String,Array{String,1}}, startyear::Integer=-1, endyear::Integer=-1; extra::Bool=false, sourceid::Integer=2, dflong::Bool=false, verbose::Bool=false)::DataFrame

Download data from World Development Indicators (WDI) Data Catalog of the World Bank.

https://datacatalog.worldbank.org/dataset/world-development-indicators

# Arguments

- `indicators` : indicator name or array of indicators
- `countries` : string or string array of ISO 2 or ISO 3 letter country codes or `all` for all countries.
- `startyear` : first year to include
- `endyear` : last year to include (required if startyear is set)
- `extra` : if `true` additional country data should be included (region, capital, longitude, latitude, income, lending)
- `sourceid` : source number, see https://api.worldbank.org/v2/sources
- `dflong` : long dataframe format. default is wide. with many indicators `long` might be easier to work with.
- `verbose` : if `true` print URLs downloaded

# Examples
```julia
df = wdi("SP.POP.TOTL", "US")
df = wdi("SP.POP.TOTL", "US", 1980, 2012)
df = wdi("SP.POP.TOTL", "USA", 1980, 2012, extra=true)
df = wdi("SP.POP.TOTL", "all", 2000, 2000, verbose=true, extra=true)
df = wdi("SP.POP.TOTL", ["US","BR"], 1980, 2012, extra=true)
df = wdi(["SP.POP.TOTL", "NY.GDP.MKTP.CD"], ["US","BR"], 1980, 2012, extra=true)
df = wdi(["SP.POP.TOTL", "NY.GDP.MKTP.CD"], ["US","BR"], 1980, 2012, dflong=true)
```
"""
function wdi(indicators::Union{String,Array{String,1}}, countries::Union{String,Array{String,1}}, startyear::Integer=-1, endyear::Integer=-1; extra::Bool=false, sourceid::Integer=2, dflong::Bool=false, verbose::Bool=false)::DataFrame
    if typeof(countries) == String
        countries = [countries]
    end

    if ! (startyear <= endyear)
        error("startyear has to be < endyear. startyear=", startyear, ". endyear=", endyear)
    end

    if typeof(indicators) == String
        indicators = [indicators]
    end

    df = wdi_download(indicators, countries, startyear, endyear, sourceid, dflong, verbose=verbose)

    if extra
        cntdat = get_countries(verbose=verbose)
        df = innerjoin(df, cntdat, on=:iso2c)
    end

    sort!(df, [order(:iso2c), order(:year)])

    df
end

end
