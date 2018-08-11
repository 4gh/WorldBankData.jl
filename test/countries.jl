module TestWDICountries

using Test
using WorldBankData


country_data = Any[ Dict("total"=>4,"per_page"=>"25000","pages"=>1,"page"=>1),
                 Any[
                    Dict("latitude"=>"42.5075","id"=>"AND","iso2Code"=>"AD","incomeLevel"=>Dict("id"=>"NOC","value"=>"High income: nonOECD"),"adminregion"=>Dict("id"=>"","value"=>""),"lendingType"=>Dict("id"=>"LNX","value"=>"Not classified"),"region"=>Dict("id"=>"ECS","value"=>"Europe & Central Asia (all income levels)"),"capitalCity"=>"Andorra la Vella","name"=>"Andorra","longitude"=>"1.5218"),
                    Dict("latitude"=>"","id"=>"ARB","iso2Code"=>"1A","incomeLevel"=>Dict("id"=>"NA","value"=>"Aggregates"),"adminregion"=>Dict("id"=>"","value"=>""),"lendingType"=>Dict("id"=>"","value"=>"Aggregates"),"region"=>Dict("id"=>"NA","value"=>"Aggregates"),"capitalCity"=>"","name"=>"Arab World","longitude"=>""),
                    Dict("latitude"=>"24.4764","id"=>"ARE","iso2Code"=>"AE","incomeLevel"=>Dict("id"=>"NOC","value"=>"High income: nonOECD"),"adminregion"=>Dict("id"=>"","value"=>""),"lendingType"=>Dict("id"=>"LNX","value"=>"Not classified"),"region"=>Dict("id"=>"MEA","value"=>"Middle East & North Africa (all income levels)"),"capitalCity"=>"Abu Dhabi","name"=>"United Arab Emirates","longitude"=>"54.3705"),
                    Dict("latitude"=>"-34.6118","id"=>"ARG","iso2Code"=>"AR","incomeLevel"=>Dict("id"=>"UMC","value"=>"Upper middle income"),"adminregion"=>Dict("id"=>"LAC","value"=>"Latin America & Caribbean (developing only)"),"lendingType"=>Dict("id"=>"IBD","value"=>"IBRD"),"region"=>Dict("id"=>"LCN","value"=>"Latin America & Caribbean (all income levels)"),"capitalCity"=>"Buenos Aires","name"=>"Argentina","longitude"=>"-58.4173"),
                 ]
               ]

df_country = WorldBankData.parse_country(country_data)

@test df_country[:name] == String["Andorra", "Arab World", "United Arab Emirates", "Argentina"]
@test df_country[:iso2c] == String["AD", "1A", "AE", "AR"]

end
