module WorldBankData

using HTTPClient.HTTPC
using JSON
using DataArrays
using DataFrames
using Compat
import Compat: UTF8String, ASCIIString

export wdi, search_wdi


function download_parse_json(url::String, verbose::Bool = false)
    if verbose
        println("download: ",url)
    end
    request = HTTPC.get(url)
    if request.http_code != 200
        error("download failed")
    end
    JSON.parse(String(request.body))
end

function parse_indicator(json::Array{Any,1})
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

function tofloat(f::AbstractString)
     try
         return float(f)
     catch
         return NA
     end
end

function parse_country(json::Array{Any,1})
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

function download_indicators()
    dat = download_parse_json("http://api.worldbank.org/indicators?per_page=25000&format=json")

    parse_indicator(dat)
end

function download_countries()
    dat = download_parse_json("http://api.worldbank.org/countries/all?per_page=25000&format=json")

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
    if any(isna(country_cache[:iso2c])) # the iso2c code for North Africa is NA
        country_cache[:iso2c][convert(DataArray{Bool,1}, isna(country_cache[:iso2c]))]="NA"
    end
end

function set_indicator_cache(df::AbstractDataFrame)
    global indicator_cache = df
end

function get_countries()
    if country_cache == false
        set_country_cache(download_countries())
    end
    country_cache
end

function get_indicators()
    if indicator_cache == false
        set_indicator_cache(download_indicators())
    end
    indicator_cache
end

regex_match(df::DataArray{String,1},regex::Regex) = convert(DataArray{Bool, 1}, map(x -> ismatch(regex,x), df))
df_match(df::AbstractDataFrame,entry::String,regex::Regex) = df[regex_match(df[make_symbol(entry)],regex),:]

function country_match(entry::String,regex::Regex)
    df = get_countries()
    df_match(df,entry,regex)
end

function indicator_match(entry::String,regex::Regex)
    df = get_indicators()
    df_match(df,entry,regex)
end

function search_countries(entry::String,regx::Regex)
    entries = ["name","region","capital","iso2c","iso3c","income","lending"]
    if !(entry in entries)
        error("unsupported country entry: \"",entry,"\". supported are:\n",entries)
    end
    country_match(entry,regx)
end

function search_indicators(entry::String,regx::Regex)
    entries = ["name","description","topics","source_database","source_organization"]
    if !(entry in entries)
        error("unsupported indicator entry: \"",entry,"\". supported are\n",entries)
    end
    indicator_match(entry,regx)
end


# examples:
#   search_wdi("countries","name",r"united"i)
#   search_wdi("indicators","description",r"gross national"i)
function search_wdi(data::String,entry::String,regx::Regex)
    data_opts = ["countries","indicators"]
    if !(data in data_opts)
        error("unsupported data source:",data,". supported are:\n",data_opts)
    end
    if data == "countries"
        return search_countries(entry,regx)
    end
    if data == "indicators"
        return search_indicators(entry,regx)
    end
end

@compat function clean_entry(x::Union{AbstractString,Void})
    if @compat(typeof(x) == Void)
        return "NA"
    else
        return x
    end
end

@compat function clean_append!(vals::Union{Array{String,1},Array{String,1}},val::Union{String,String,Void})
    append!(vals,[clean_entry(val)])
end

# The "." character is illegal in symbol, but used a lot in WDI. replace by "_".
# example: NY.GNP.PCAP.CD becomes NY_GNP_PCAP_CD
function make_symbol(x::String)
    Symbol(replace(x, ".", "_"))
end

@compat function convert_a2f(x::Union{Array{String,1},Array{String,1}})
    n = length(x)
    arr = @data(zeros(n))
    for i in 1:n
        arr[i]=tofloat(x[i])
    end
    arr
end

function parse_wdi(indicator::String, json, startyear::Integer, endyear::Integer)
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

    # filter missing/wrong data
    complete_cases!(df)

    checkyear(x) = (x >= startyear) & (x <= endyear)
    yind = map(checkyear,df[:year])
    yind = convert(DataArray{Bool, 1}, yind)
    df[yind, :]
end

@compat function wdi_download(indicator::String, country::Union{String,Array{String,1}}, startyear::Integer, endyear::Integer)
    if typeof(country) == String
        url = string("http://api.worldbank.org/countries/", country, "/indicators/", indicator,
                  "?date=", startyear,":", endyear, "&per_page=25000", "&format=json")
        json = [download_parse_json(url)[2]]
    elseif typeof(country) == Array{String,1}
        json = Any[]
        for c in country
            url = string("http://api.worldbank.org/countries/", c, "/indicators/", indicator,
                         "?date=", startyear,":", endyear, "&per_page=25000", "&format=json")
            append!(json,[download_parse_json(url)[2];])
        end
    end

    parse_wdi(indicator,json, startyear, endyear)
end

all_countries = ["AW", "AF", "A9", "AO", "AL", "AD", "1A", "AE", "AR", "AM", "AS", "AG", "AU", "AT", "AZ", "BI", "BE", "BJ", "BF", "BD", "BG", "BH", "BS", "BA", "BY", "BZ", "BM", "BO", "BR", "BB", "BN", "BT", "BW", "C9", "CF", "CA", "C4", "C5", "CH", "JG", "CL", "CN", "CI", "C6", "C7", "CM", "CD", "CG", "CO", "KM", "CV", "CR", "C8", "S3", "CU", "CW", "KY", "CY", "CZ", "DE", "DJ", "DM", "DK", "DO", "DZ", "4E", "Z4", "7E", "Z7", "EC", "EG", "XC", "ER", "ES", "EE", "ET", "EU", "FI", "FJ", "FR", "FO", "FM", "GA", "GB", "GE", "GH", "GN", "GM", "GW", "GQ", "GR", "GD", "GL", "GT", "GU", "GY", "XD", "HK", "HN", "XE", "HR", "HT", "HU", "ID", "IM", "IN", "XY", "IE", "IR", "IQ", "IS", "IL", "IT", "JM", "JO", "JP", "KZ", "KE", "KG", "KH", "KI", "KN", "KR", "KV", "KW", "XJ", "LA", "LB", "LR", "LY", "LC", "ZJ", "XL", "XM", "LI", "LK", "XN", "XO", "LS", "LT", "LU", "LV", "MO", "MF", "MA", "MC", "MD", "MG", "MV", "ZQ", "MX", "MH", "XP", "MK", "ML", "MT", "MM", "XQ", "ME", "MN", "MP", "MZ", "MR", "MU", "MW", "MY", "XU", "M2", "NA", "NC", "NE", "NG", "NI", "NL", "XR", "NO", "NP", "NZ", "XS", "OE", "OM", "S4", "PK", "PA", "PE", "PH", "PW", "PG", "PL", "PR", "KP", "PT", "PY", "PS", "S2", "PF", "QA", "RO", "RU", "RW", "8S", "SA", "SD", "SN", "SG", "SB", "SL", "SV", "SM", "SO", "RS", "ZF", "SS", "ZG", "S1", "ST", "SR", "SK", "SI", "SE", "SZ", "SX", "A4", "SC", "SY", "TC", "TD", "TG", "TH", "TJ", "TM", "TL", "TO", "TT", "TN", "TR", "TV", "TW", "TZ", "UG", "UA", "XK", "XT", "UY", "US", "UZ", "VC", "VE", "VI", "VN", "VU", "1W", "WS", "A5", "YE", "ZA", "ZM", "ZW" ]


# example:
#   df=wdi("NY.GNP.PCAP.CD", ["US","BR"], 1980, 2012, true)
@compat function wdi(indicators::Union{String,Array{String,1}},countries::Union{String,Array{String,1}},startyear::Integer=1800,endyear::Integer=3000,extra::Bool=false)
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

    df = DataFrame()

    if typeof(indicators) == String
        indicators=[indicators]
    end

    for ind in indicators
        dfn = wdi_download(ind, countries, startyear, endyear)
        df = vcat(df,dfn)
    end

    if extra
        cntdat = get_countries()
        df = join(df,cntdat,on=:iso2c)
    end

    df
end


end
