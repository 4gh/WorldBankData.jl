using SafeTestsets

@time @safetestset "is formatted" begin
    include("isformatted.jl")
end
@time @safetestset "countries" begin
    include("countries.jl")
end
@time @safetestset "get_url" begin
    include("get_url.jl")
end
@time @safetestset "bad arguments" begin
    include("bad_arguments.jl")
end
@time @safetestset "indicators" begin
    include("indicators.jl")
end
@time @safetestset "wdi" begin
    include("wdi.jl")
end
@time @safetestset "search wdi" begin
    include("search_wdi.jl")
end
@time @safetestset "jsonwdi" begin
    include("jsonwdi.jl")
end
@time @safetestset "check all_countries status" begin
    include("check_all_countries.jl")
end

# example_dl.jl downloads data from the world bank web site.
# The data gets revised occasionally which breaks the test.
@time @safetestset "example download wide format" begin
    include("example_dl.jl")
end
@time @safetestset "example download long format" begin
    include("example_dl_long.jl")
end
