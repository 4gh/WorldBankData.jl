module TestParseWDI

using Base.Test
using WorldBankData
using Compat


us_gnp_data = @compat Any[  Dict( "total"=>23,"per_page"=>"25000","pages"=>1,"page"=>1 ),
                 Any[ Dict("date"=>"2012","value"=>"52340","indicator"=>Dict("id"=>"NY.GNP.PCAP.CD","value"=>"GNI per capita, Atlas method (current US\$)"),"country"=>Dict("id"=>"US","value"=>"United States"),"decimal"=>"0"),
                   Dict("date"=>"2011","value"=>"50650","indicator"=>Dict("id"=>"NY.GNP.PCAP.CD","value"=>"GNI per capita, Atlas method (current US\$)"),"country"=>Dict("id"=>"US","value"=>"United States"),"decimal"=>"0"),
                   Dict("date"=>"2010","value"=>"48960","indicator"=>Dict("id"=>"NY.GNP.PCAP.CD","value"=>"GNI per capita, Atlas method (current US\$)"),"country"=>Dict("id"=>"US","value"=>"United States"),"decimal"=>"0"),
                   Dict("date"=>"2009","value"=>"48040","indicator"=>Dict("id"=>"NY.GNP.PCAP.CD","value"=>"GNI per capita, Atlas method (current US\$)"),"country"=>Dict("id"=>"US","value"=>"United States"),"decimal"=>"0"),
                   Dict("date"=>"2008","value"=>"49350","indicator"=>Dict("id"=>"NY.GNP.PCAP.CD","value"=>"GNI per capita, Atlas method (current US\$)"),"country"=>Dict("id"=>"US","value"=>"United States"),"decimal"=>"0"),
                   Dict("date"=>"2007","value"=>"48640","indicator"=>Dict("id"=>"NY.GNP.PCAP.CD","value"=>"GNI per capita, Atlas method (current US\$)"),"country"=>Dict("id"=>"US","value"=>"United States"),"decimal"=>"0"),
                   Dict("date"=>"2006","value"=>"48080","indicator"=>Dict("id"=>"NY.GNP.PCAP.CD","value"=>"GNI per capita, Atlas method (current US\$)"),"country"=>Dict("id"=>"US","value"=>"United States"),"decimal"=>"0")
                 ]
              ]


us_gnp = WorldBankData.parse_wdi("NY.GNP.PCAP.CD",us_gnp_data[2],2006,2012)

@test us_gnp[:year] == Float64[2012, 2011, 2010, 2009, 2008, 2007, 2006]
@test us_gnp[:NY_GNP_PCAP_CD] == Float64[52340, 50650, 48960, 48040, 49350, 48640, 48080]

end
