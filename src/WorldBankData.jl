module WorldBankData

using HTTPClient.HTTPC
using JSON
using DataArrays
using DataFrames

export wdi, search_wdi


function download_parse_json(url::ASCIIString)
    println("download: ",url)
    request = HTTPC.get(url)
    if request.http_code != 200
        error("download failed")
    end
    JSON.parse(bytestring(request.body))
end

function parse_indicator(json::Array{Any,1})
    indicator = ASCIIString[]
    name = UTF8String[]
    description = UTF8String[]
    source_database = UTF8String[]
    source_organization = UTF8String[]

    for d in json[2]
        append!(indicator,[d["id"]])
        append!(name,[d["name"]])
        append!(description,[d["sourceNote"]])
        append!(source_database, [d["source"]["value"]])
        append!(source_organization, [d["sourceOrganization"]])
    end

    DataFrame({"indicator" => indicator, "name" => name,
               "description" => description, "source_database" => source_database,
               "source_organization" => source_organization})
end

function tofloat(f::String)
     try
         return float(f)
     catch
         return NA
     end
end

function parse_country(json::Array{Any,1})
    iso3c = ASCIIString[]
    iso2c = ASCIIString[]
    name = UTF8String[]
    region = UTF8String[]
    capital = UTF8String[]
    longitude = UTF8String[]
    latitude = UTF8String[]
    income = UTF8String[]
    lending = UTF8String[]

    for d in json[2]
        append!(iso3c,[d["id"]])
        append!(iso2c,[d["iso2Code"]])
        append!(name,[d["name"]])
        append!(region,[d["region"]["value"]])
        append!(capital,[d["capitalCity"]])
        append!(longitude,[d["longitude"]])
        append!(latitude,[d["latitude"]])
        append!(income,[d["incomeLevel"]["value"]])
        append!(lending,[d["lendingType"]["value"]])
    end

    longitude = [tofloat(i) for i in longitude]
    latitude = [tofloat(i) for i in latitude]

    DataFrame({ "iso3c" => iso3c, "iso2c" => iso2c, "name" => name,
                "region" => region, "capital" => capital, "longitude" => longitude,
                "latitude" => latitude, "income" => income, "lending" => lending })
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

function set_country_cache(df::AbstractDataFrame)
    global country_cache = df
    if any(isna(country_cache["iso2c"])) # the iso2c code for North Africa is NA
        country_cache["iso2c"][convert(DataArray{Bool,1}, isna(country_cache["iso2c"]))]="NA"
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

regex_match(df::DataArray{UTF8String,1},regex::Regex) = convert(DataArray{Bool, 1}, map(x -> ismatch(regex,x), df))
df_match(df::AbstractDataFrame,entry::ASCIIString,regex::Regex) = df[regex_match(df[entry],regex),:]

function country_match(entry::ASCIIString,regex::Regex)
    df = get_countries()
    df_match(df,entry,regex)
end

function indicator_match(entry::ASCIIString,regex::Regex)
    df = get_indicators()
    df_match(df,entry,regex)
end

function search_countries(entry::ASCIIString,regx::Regex)
    entries = ["name","region","capital","iso2c","iso3c","income","lending"]
    if !(entry in entries)
        error("unsupported country entry: \"",entry,"\". supported are:\n",entries)
    end
    country_match(entry,regx)
end

function search_indicators(entry::ASCIIString,regx::Regex)
    entries = ["name","description","topics","source_database","source_organization"]
    if !(entry in entries)
        error("unsupported indicator entry: \"",entry,"\". supported are\n",entries)
    end
    indicator_match(entry,regx)
end


# examples:
#   search_wdi("countries","name",r"united"i)
#   search_wdi("indicators","description",r"gross national"i)
function search_wdi(data::ASCIIString,entry::ASCIIString,regx::Regex)
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

function clean_entry(x::Union(String,Nothing))
    if typeof(x) == Nothing
        return "NA"
    else
        return x
    end
end

function clean_append!(vals::Union(Array{UTF8String,1},Array{ASCIIString,1}),val::Union(UTF8String,ASCIIString,Nothing))
    append!(vals,[clean_entry(val)])
end

function parse_wdi(indicator::ASCIIString, json, startyear::Integer, endyear::Integer)
    country_id = ASCIIString[]
    country_name = UTF8String[]
    value = ASCIIString[]
    date = ASCIIString[]

    for d in json
        clean_append!(country_id,d["country"]["id"])
        clean_append!(country_name,d["country"]["value"])
        clean_append!(value,d["value"])
        clean_append!(date,d["date"])
    end

    value = float64(DataArray(Any[tofloat(i) for i in value]))
    date = float64(DataArray(Any[tofloat(i) for i in date]))

    df = DataFrame({ "iso2c" => country_id, "country" => country_name })
    df[string(indicator)] = value
    df["year"] = date

    # filter missing/wrong data
    complete_cases!(df)

    checkyear(x) = (x >= startyear) & (x <= endyear)
    yind = map(checkyear,df["year"])
    yind = convert(DataArray{Bool, 1}, yind)
    df[yind, :]
end

function wdi_download(indicator::ASCIIString, country::Union(ASCIIString,Array{ASCIIString,1}), startyear::Integer, endyear::Integer)
    if typeof(country) == ASCIIString
        url = string("http://api.worldbank.org/countries/", country, "/indicators/", indicator,
                  "?date=", startyear,":", endyear, "&per_page=25000", "&format=json")
        json = [download_parse_json(url)[2]]
    elseif typeof(country) == Array{ASCIIString,1}
        json = Any[]
        for c in country
            url = string("http://api.worldbank.org/countries/", c, "/indicators/", indicator,
                         "?date=", startyear,":", endyear, "&per_page=25000", "&format=json")
            append!(json,[download_parse_json(url)[2]])
        end
    end

    parse_wdi(indicator,json, startyear, endyear)
end

all_countries = ["AW", "AF", "A9", "AO", "AL", "AD", "1A", "AE", "AR", "AM", "AS", "AG", "AU", "AT", "AZ", "BI", "BE", "BJ", "BF", "BD", "BG", "BH", "BS", "BA", "BY", "BZ", "BM", "BO", "BR", "BB", "BN", "BT", "BW", "C9", "CF", "CA", "C4", "C5", "CH", "JG", "CL", "CN", "CI", "C6", "C7", "CM", "CD", "CG", "CO", "KM", "CV", "CR", "C8", "S3", "CU", "CW", "KY", "CY", "CZ", "DE", "DJ", "DM", "DK", "DO", "DZ", "4E", "Z4", "7E", "Z7", "EC", "EG", "XC", "ER", "ES", "EE", "ET", "EU", "FI", "FJ", "FR", "FO", "FM", "GA", "GB", "GE", "GH", "GN", "GM", "GW", "GQ", "GR", "GD", "GL", "GT", "GU", "GY", "XD", "HK", "HN", "XE", "HR", "HT", "HU", "ID", "IM", "IN", "XY", "IE", "IR", "IQ", "IS", "IL", "IT", "JM", "JO", "JP", "KZ", "KE", "KG", "KH", "KI", "KN", "KR", "KV", "KW", "XJ", "LA", "LB", "LR", "LY", "LC", "ZJ", "XL", "XM", "LI", "LK", "XN", "XO", "LS", "LT", "LU", "LV", "MO", "MF", "MA", "MC", "MD", "MG", "MV", "ZQ", "MX", "MH", "XP", "MK", "ML", "MT", "MM", "XQ", "ME", "MN", "MP", "MZ", "MR", "MU", "MW", "MY", "XU", "M2", "NA", "NC", "NE", "NG", "NI", "NL", "XR", "NO", "NP", "NZ", "XS", "OE", "OM", "S4", "PK", "PA", "PE", "PH", "PW", "PG", "PL", "PR", "KP", "PT", "PY", "PS", "S2", "PF", "QA", "RO", "RU", "RW", "8S", "SA", "SD", "SN", "SG", "SB", "SL", "SV", "SM", "SO", "RS", "ZF", "SS", "ZG", "S1", "ST", "SR", "SK", "SI", "SE", "SZ", "SX", "A4", "SC", "SY", "TC", "TD", "TG", "TH", "TJ", "TM", "TL", "TO", "TT", "TN", "TR", "TV", "TZ", "UG", "UA", "XT", "UY", "US", "UZ", "VC", "VE", "VI", "VN", "VU", "1W", "WS", "A5", "YE", "ZA", "ZM", "ZW" ]


# example:
#   df=wdi("NY.GNP.PCAP.CD", ["US","BR"], 1980, 2012, true)
function wdi(indicators::Union(ASCIIString,Array{ASCIIString,1}),countries::Union(ASCIIString,Array{ASCIIString,1}),startyear::Integer=1800,endyear::Integer=3000,extra::Bool=false)
    if countries == "all"
        countries = all_countries
    end

    if typeof(countries) == ASCIIString
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

    if typeof(indicators) == ASCIIString
        indicators=[indicators]
    end

    for ind in indicators
        dfn = wdi_download(ind, countries, startyear, endyear)
        df = vcat(df,dfn)
    end

    if extra
        cntdat = getCountries()
        df = join(df,cntdat)
    end

    df
end


end
