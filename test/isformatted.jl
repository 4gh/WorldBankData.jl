using Test
using WorldBankData
using FilePathsBase
using JuliaFormatter

# find_jl_files returns a vector of filenames of julia source code files.
function find_jl_files()
    jlfiles = String[]
    for (root, dirs, files) in walkdir("..") # .. since Pkg.test() runs in ./test directory
        for f in files
            if endswith(f, ".jl")
                push!(jlfiles, joinpath(root, f))
            end
        end
    end
    return jlfiles
end

# is_formatted returns true if all .jl files in the repository are formatted according to JuliaFormatter.
function is_formatted()
    jlfiles = find_jl_files()
    for f in jlfiles
        println("[INFO] check formatting of file $f.")
        str = String(read(f))
        if str != format_text(str)
            println("[WARN] file $f is not formatted correctly.")
            return false
        end
    end
    return true
end

@test is_formatted()
