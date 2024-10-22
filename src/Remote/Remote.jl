module Remote
using CSV
using FileIO
using DataFrames
using FileWatching


include("sbatchScriptGenerator.jl")

struct Cluster
    host_name::String
    user::String
    identity_file::String
    password::String
    workingDir::String
    load_juliaANDmpi_cmd::String
    MPI_use_system_binary::Bool
end

function addCluster(user::String, host_name::String, identity_file::String; password="", workingDir="", load_juliaANDmpi_cmd="", MPI_use_system_binary=true)
    if !isfile("remotes.csv")

        CSV.write("remotes.csv", DataFrame(host_name=[host_name], user=[user], identity_file=[identity_file], password=[password], workingDir=[workingDir], load_juliaANDmpi_cmd=[load_juliaANDmpi_cmd], MPI_use_system_binary=[MPI_use_system_binary]))

    else
        df = DataFrame(CSV.File("remotes.csv"))

        if isempty(df[df.host_name.==host_name, :])
            push!(df, (host_name, user, identity_file, password, workingDir, load_juliaANDmpi_cmd, MPI_use_system_binary); promote=true)
            CSV.write("remotes.csv", df)
        else
            println("Cluster $(host_name) already exists. Please use loadCluster(\"$host_name\") to load the cluster.")
            return Cluster(host_name, user, identity_file, password, workingDir, load_juliaANDmpi_cmd, MPI_use_system_binary)
        end
    end
    try
        mkpath("remotes/$(host_name)")
    catch
        println("Directory remotes/$(host_name) already exists.")
    end
    cluster = Cluster(host_name, user, identity_file, password, workingDir, load_juliaANDmpi_cmd, MPI_use_system_binary)
    println("Cluster $(host_name) added successfully. Connecting...")
    connect(cluster)
    println("Setting up...")
    setup(cluster)
    println("Disconnecting...")
    disconnect(cluster)
    return cluster
end

function loadCluster(host_name::String)
    df = DataFrame(CSV.File("remotes.csv"))
    row = df[df.host_name.==host_name, :]
    if isempty(row)
        println("Cluster $(host_name) not found. Run showClusters() to see all clusters.")
        return nothing
    end
    user = row.user[1]
    identity_file = row.identity_file[1]
    password = row.password[1]
    workingDir = row.workingDir[1]
    load_juliaANDmpi_cmd = row.load_juliaANDmpi_cmd[1]
    MPI_use_system_binary = row.MPI_use_system_binary[1]
    if password === missing
        return Cluster(host_name, user, identity_file, "", workingDir, load_juliaANDmpi_cmd, MPI_use_system_binary)
    else
        return Cluster(host_name, user, identity_file, password, workingDir, load_juliaANDmpi_cmd, MPI_use_system_binary)
    end
end

function loadCluster(id::Integer)
    df = DataFrame(CSV.File("remotes.csv"))
    row = df[id, :]
    if isempty(row)
        println("Cluster $(id) not found. Run showClusters() to see all clusters.")
        return nothing
    end
    host_name = row.host_name
    user = row.user
    identity_file = row.identity_file
    password = row.password
    workingDir = row.workingDir
    load_juliaANDmpi_cmd = row.load_juliaANDmpi_cmd
    MPI_use_system_binary = row.MPI_use_system_binary
    if password === missing
        return Cluster(host_name, user, identity_file, "", workingDir, load_juliaANDmpi_cmd, MPI_use_system_binary)
    else
        return Cluster(host_name, user, identity_file, password, workingDir, load_juliaANDmpi_cmd, MPI_use_system_binary)
    end
end

function showClusters()
    if !isfile("remotes.csv")
        println("No clusters added.")
        return nothing
    else
        df = DataFrame(CSV.File("remotes.csv"))
        return df
    end
end

function connect(cluster::Cluster)
    try
        rm("remotes/$(cluster.host_name)/$(cluster.host_name).log")
        disconnect(cluster)
    catch
    end
    println("Creating screen session \"$(cluster.host_name)\"...")
    run(`screen -L -Logfile remotes/$(cluster.host_name)/$(cluster.host_name).log -dmS $(cluster.host_name)`)
    println("Connecting to \"$(cluster.host_name)\"...")
    run(`screen -S $(cluster.host_name) -X stuff "ssh -i $(cluster.identity_file) $(cluster.user)@$(cluster.host_name) \n"`)
    if cluster.password == ""
        waitForRemote(cluster)
    else
        println("Entering password")
        waitForRemote(cluster; cue=raw": ")
        run(`screen -S $(cluster.host_name) -X stuff "$(cluster.password)\n"`)
        waitForRemote(cluster)
    end
    println("Connected!")
    return nothing
end

function setup(cluster::Cluster)

    if !isfile(".env")
        println("No .env file found. Please create a .env file with the following format:")
        println("GITHUB_USERNAME=<username>")
        println("GITHUB_PASSWORD=<accesstoken>")
        return nothing
    end

    println("Creating directory MonitoredQuantumCircuitsENV/...")
    run(`screen -S $(cluster.host_name) -X stuff "cd $(cluster.workingDir); mkdir MonitoredQuantumCircuitsENV; cd MonitoredQuantumCircuitsENV\n"`)
    waitForRemote(cluster)
    upload(cluster, joinpath(@__DIR__, "execScript.jl"), "MonitoredQuantumCircuitsENV/")
    println("Adding packages...")
    df = DataFrame(CSV.File(".env", delim='=', header=-1))
    row = df[df.Column1.=="GITHUB_USERNAME", :]
    github_username = row.Column2[1]
    row = df[df.Column1.=="GITHUB_PASSWORD", :]
    github_password = row.Column2[1]
    run(`screen -S $(cluster.host_name) -X stuff "$(cluster.load_juliaANDmpi_cmd)\n"`)
    waitForRemote(cluster)
    run(`screen -S $(cluster.host_name) -X stuff "julia -e 'using Pkg; Pkg.activate(\".\");Pkg.add(PackageSpec(url=\"https://$(github_username):$(github_password)@github.com/J-C-Q/MonitoredQuantumCircuits.jl.git\", rev=\"main\")); Pkg.add(\"JLD2\"); Pkg.add(\"MPI\")'\n"`)
    waitForRemote(cluster)
    println("Instantiating packages...")
    run(`screen -S $(cluster.host_name) -X stuff "julia --project -e 'using Pkg; Pkg.instantiate()'\n"`)
    waitForRemote(cluster)
    println("Loading python deps...")
    run(`screen -S $(cluster.host_name) -X stuff "julia --project -e 'using MonitoredQuantumCircuits'\n"`)
    waitForRemote(cluster)
    if cluster.MPI_use_system_binary
        run(`screen -S $(cluster.host_name) -X stuff "julia --project -e 'using MPI.MPIPreferences; MPIPreferences.use_system_binary()'\n"`)
        waitForRemote(cluster)
    end
    run(`screen -S $(cluster.host_name) -X stuff "echo setup done!\n"`)
    waitForRemote(cluster)
    println("Cluster $(cluster.host_name) is ready to use.")
    return nothing
end

function upload(cluster::Cluster, file::String, destination::String="")
    println("Uploading file to \"$(cluster.host_name)\"...")
    run(`scp -i $(cluster.identity_file) $(file) $(cluster.user)@$(cluster.host_name):$(cluster.workingDir)/$(destination)`)
end

function refreshFiles(cluster::Cluster, directory::String)
    # This is usefull if files in the working directory will be deleated after some time (relative to the modification date)
    run(`screen -S $(cluster.host_name) -X stuff "find $(cluster.workingDir)/$(directory) -type f -exec touch {} \; \n"`)
end

function mkdir(cluster::Cluster, directory::String)
    println("Creating directory \"$(directory)\" on \"$(cluster.host_name)\"...")
    run(`screen -S $(cluster.host_name) -X stuff "mkdir $(cluster.workingDir)/$(directory)\n"`)
    waitForRemote(cluster)
    return nothing
end

function toDataframe(lines::Vector{String})
    # Join the list of strings into a single string with newline characters
    csv_data = join(lines, "\n")

    # Create an IOBuffer from the CSV data string
    io = IOBuffer(csv_data)

    # Use CSV.read to parse the data into a DataFrame
    df = CSV.read(io, DataFrame, delim=' ', ignorerepeated=true, header=1)

    return df
end

function waitForRemote(cluster::Cluster; cue=raw"$ ")
    ready = false
    while !ready
        FileWatching.watch_file("remotes/$(cluster.host_name)/$(cluster.host_name).log")
        cueLength = length(cue)
        open("remotes/$(cluster.host_name)/$(cluster.host_name).log", "r") do io
            # Move the pointer
            seek(io, max(filesize(io) - cueLength, 0))

            # Read the last bytes and convert them to characters
            last_chars = String(read(io, cueLength))
            if last_chars == cue
                ready = true
            end
        end
    end
    return nothing
end

function getQueue(cluster::Cluster)
    println("Getting queue from \"$(cluster.host_name)\"...")
    line1 = open("remotes/$(cluster.host_name)/$(cluster.host_name).log", "r") do file
        countlines(file)
    end
    run(`screen -S $(cluster.host_name) -X stuff "squeue -u $(cluster.user)\n"`)

    waitForRemote(cluster)

    line2 = open("remotes/$(cluster.host_name)/$(cluster.host_name).log", "r") do file
        countlines(file)
    end

    nlines = line2 - line1
    lines = open("remotes/$(cluster.host_name)/$(cluster.host_name).log", "r") do file
        last(eachline(file), nlines)
    end


    return toDataframe(lines[1:end-1])
end

function queueJob(cluster::Cluster, bashFile::String, path::String)
    println("Queueing job on \"$(cluster.host_name)\"...")
    run(`screen -S $(cluster.host_name) -X stuff "cd $(cluster.workingDir)/$(path)\n"`)
    waitForRemote(cluster)
    run(`screen -S $(cluster.host_name) -X stuff "sbatch $(bashFile)\n"`)
    waitForRemote(cluster)
    run(`screen -S $(cluster.host_name) -X stuff "cd -\n"`)
    waitForRemote(cluster)
    # lines = open("remotes/$(cluster.host_name)/$(cluster.host_name).log", "r") do file
    #     last(eachline(file), 2)
    # end
    # return lines[1]
    return nothing
end

function downloadResults(cluster::Cluster, file::String)
    println("Downloading results from \"$(cluster.host_name)\"...")
    run(`screen -S $(cluster.host_name) -X stuff "$(file)\n"`)
    run(`scp -i $(cluster.identity_file) $(cluster.user)@$(cluster.host_name):$(file) .`)
    return nothing
end

function hostname(cluster::Cluster)
    run(`screen -S $(cluster.host_name) -X stuff "hostname\n"`)
    waitForRemote(cluster)
    lines = open("remotes/$(cluster.host_name)/$(cluster.host_name).log", "r") do file
        last(eachline(file), 2)
    end
    return lines[1]
end

function isConnected(cluster::Cluster)
    run(`screen -S $(cluster.host_name) -X stuff "echo \\\$SSH_CONNECTION\n"`)
    waitForRemote(cluster)
    lines = open("remotes/$(cluster.host_name)/$(cluster.host_name).log", "r") do file
        last(eachline(file), 2)
    end
    return lines[1] != ""
end

function getInfo()


end

function connectedClusters()
    if !isfile("remotes.csv")
        println("No clusters added.")
        return nothing
    end
    output = ""
    try
        output = read(`screen -ls`, String)
    catch
        isinteractive() && println("No clusters connected.")
        return nothing
    end
    lines = split(output, "\n")
    screen_names = filter(line -> contains(line, "\t"), lines)
    screen_names = [n[2] for n in split.(screen_names, "\t")]
    names = [n[2] for n in split.(screen_names, "."; limit=2)]
    df = showClusters()
    clusters = Cluster[]
    for host_name in names
        row = df[df.host_name.==host_name, :]
        if !isempty(row)
            push!(clusters, loadCluster(string(host_name)))
        end
    end

    return clusters
end

function disconnect(cluster::Cluster)
    println("Disconnecting from \"$(cluster.host_name)\"...")
    run(`screen -S $(cluster.host_name) -X quit`)
    return nothing
end

function disconnectAll()
    if connectedClusters() === nothing
        return nothing
    end
    for cluster in connectedClusters()
        disconnect(cluster)
    end
    return nothing
end

atexit(disconnectAll)

# # overwrite show method for DataFrames
# function Base.show(io::IO,
#     df::AbstractDataFrame;
#     allrows::Bool=!get(io, :limit, false),
#     allcols::Bool=!get(io, :limit, false),
#     rowlabel::Symbol=:Row,
#     summary::Bool=true,
#     eltypes::Bool=false,
#     truncate::Int=32,
#     kwargs...)

#     # Check for keywords that are valid in other backends but not here.
#     DataFrames._verify_kwargs_for_text(; kwargs...)

#     DataFrames._show(io, df; allrows=allrows, allcols=allcols, rowlabel=rowlabel,
#         summary=summary, eltypes=eltypes, truncate=truncate, kwargs...)
# end

end
