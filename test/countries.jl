module TestWDICountries

using Base.Test
using WorldBankData

country_data = { { "total"=>4,"per_page"=>"25000","pages"=>1,"page"=>1 },
                 {
                    ["latitude"=>"42.5075","id"=>"AND","iso2Code"=>"AD","incomeLevel"=>["id"=>"NOC","value"=>"High income: nonOECD"],"adminregion"=>["id"=>"","value"=>""],"lendingType"=>["id"=>"LNX","value"=>"Not classified"],"region"=>["id"=>"ECS","value"=>"Europe & Central Asia (all income levels)"],"capitalCity"=>"Andorra la Vella","name"=>"Andorra","longitude"=>"1.5218"],
                    ["latitude"=>"","id"=>"ARB","iso2Code"=>"1A","incomeLevel"=>["id"=>"NA","value"=>"Aggregates"],"adminregion"=>["id"=>"","value"=>""],"lendingType"=>["id"=>"","value"=>"Aggregates"],"region"=>["id"=>"NA","value"=>"Aggregates"],"capitalCity"=>"","name"=>"Arab World","longitude"=>""],
                    ["latitude"=>"24.4764","id"=>"ARE","iso2Code"=>"AE","incomeLevel"=>["id"=>"NOC","value"=>"High income: nonOECD"],"adminregion"=>["id"=>"","value"=>""],"lendingType"=>["id"=>"LNX","value"=>"Not classified"],"region"=>["id"=>"MEA","value"=>"Middle East & North Africa (all income levels)"],"capitalCity"=>"Abu Dhabi","name"=>"United Arab Emirates","longitude"=>"54.3705"],
                    ["latitude"=>"-34.6118","id"=>"ARG","iso2Code"=>"AR","incomeLevel"=>["id"=>"UMC","value"=>"Upper middle income"],"adminregion"=>["id"=>"LAC","value"=>"Latin America & Caribbean (developing only)"],"lendingType"=>["id"=>"IBD","value"=>"IBRD"],"region"=>["id"=>"LCN","value"=>"Latin America & Caribbean (all income levels)"],"capitalCity"=>"Buenos Aires","name"=>"Argentina","longitude"=>"-58.4173"]
                 }
               }
df_country = WorldBankData.parse_country(country_data)

@test df_country["name"] == UTF8String["Andorra", "Arab World", "United Arab Emirates", "Argentina"]
@test df_country["iso2c"] == ASCIIString["AD", "1A", "AE", "AR"]

end
