using Test
using WorldBankData

include("isformatted.jl")
include("countries.jl")
include("bad_arguments.jl")
include("indicators.jl")
include("wdi.jl")
include("search_wdi.jl")
include("jsonwdi.jl")
include("check_all_countries.jl")

# example_dl.jl downloads data from the world bank web site.
# The data gets revised occasionally which breaks the test.
include("example_dl.jl")
