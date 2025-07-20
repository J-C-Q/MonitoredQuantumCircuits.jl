using JLD2


function combine_data!(folders::Vector{String}, L=128, depth=15)
    combined_entanglement = Float64[]
    combined_error = Float64[]
    combined_probabilities = Float64[]
    combined_depth = depth
    combined_L = L
    combined_averaging = Int[]

    for data_path in folders

        files = readdir(data_path, join=true)


        entanglement = Float64[]
        error = Float64[]
        probabilities = Float64[]
        depths = Int[]
        Ls = Int[]
        averaging = Int[]

        for f in files
            data = JLD2.load(f)
            push!(entanglement, data["entanglement"])
            push!(error, data["error"])
            push!(probabilities, data["probability"])
            push!(depths, data["depth"])
            push!(Ls, data["system_size"])
            push!(averaging, data["samples"])
        end

        if all(Ls .== Ls[1]) && all(depths .== depths[1])
            if Ls[1] == combined_L && depths[1] == combined_depth
                for (i,p) in enumerate(probabilities)
                    # find if p is already in combined_probabilities
                    if p in combined_probabilities
                        idx = findfirst(isequal(p), combined_probabilities)
                        combined_entanglement[idx] = combined_entanglement[idx]*combined_averaging[idx] + entanglement[i] * averaging[i]
                        combined_averaging[idx] += averaging[i]
                        combined_entanglement[idx] /= combined_averaging[idx]
                        combined_error[idx] = sqrt(combined_error[idx]^2 * (combined_averaging[idx] - averaging[i]) / combined_averaging[idx] + error[i]^2 * averaging[i] / combined_averaging[idx])


                    else
                        push!(combined_probabilities, p)
                        push!(combined_entanglement, entanglement[i])
                        push!(combined_error, error[i])
                        push!(combined_averaging, averaging[i])
                    end
                end

            end
        end
    end
    for (i,p) in enumerate(combined_probabilities)
        JLD2.save(
            "combined/combined_L$(L)_D$(depth)/ENTh_avg$(combined_averaging[i])_p$(p).jld2",
            "probability", p,
            "entanglement", combined_entanglement[i],
            "error", combined_error[i],
            "depth", combined_depth,
            "system_size", combined_L,
            "samples", combined_averaging[i])
    end
end
