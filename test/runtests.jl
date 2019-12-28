using Test
using WorldBankData

include("countries.jl")
include("indicators.jl")
include("wdi.jl")
include("search_wdi.jl")
include("jsonwdi.jl")

# example_dl.jl test downloads data from the world bank web site.
# The data gets revised occasionally which breaks the test.
#include("example_dl.jl")
