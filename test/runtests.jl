using Test
using WorldBankData

# example_dl.jl test downloads test data from web site.
# The data gets revised occasionally which breaks the test.
# my_tests = ["countries.jl", "indicators.jl", "wdi.jl", "search_wdi.jl", "jsonwdi.jl", "example_dl.jl"]

my_tests = ["countries.jl", "indicators.jl", "wdi.jl", "search_wdi.jl", "jsonwdi.jl"]

println("Running tests:")

for my_test in my_tests
    println(" * $(my_test)")
    include(my_test)
end
