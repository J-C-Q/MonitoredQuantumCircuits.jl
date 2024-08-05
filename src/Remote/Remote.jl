module Remote
using CSV
using FileIO
using DataFrames
using FileWatching
export addCluster
export loadCluster

# include("sbatchScriptGenerator.jl")

struct Cluster
    host_name::String
    user::String
    identity_file::String
    password::String


end

function addCluster(user::String, host_name::String, identity_file::String)
    if !isfile("remotes.csv")
        CSV.write("remotes.csv", DataFrame(host_name=[host_name], user=[user], identity_file=[identity_file]))
    else
        df = DataFrame(CSV.File("remotes.csv"))

        if isempty(df[df.host_name.==host_name, :])
            push!(df, (host_name, user, identity_file))
            CSV.write("remotes.csv", df)
        else
            println("Cluster $(host_name) already exists. Please use loadCluster(\"$host_name\") to load the cluster.")
            return Cluster(host_name, user, identity_file, "")
        end
    end
    try
        mkdir("remote/$(host_name)")
    catch
    end
    cluster = Cluster(host_name, user, identity_file, "")
    println("Cluster $(host_name) added successfully. Connecting...")
    connect(cluster)
    println("Setting up...")
    setup(cluster)
    println("Cluster $(host_name) is ready to use. Disconnecting...")
    disconnect(cluster)
    return cluster
end

function loadCluster(host_name::String)
    df = DataFrame(CSV.File("remotes.csv"))
    row = df[df.host_name.==host_name, :]
    user = row.user[1]
    identity_file = row.identity_file[1]
    return Cluster(host_name, user, identity_file, "")
end

function showClusters()
    df = DataFrame(CSV.File("remotes.csv"))
    println(df)
end

function connect(cluster::Cluster)
    try
        rm("remotes/$(cluster.host_name)/$(cluster.host_name).log")
        disconnect(cluster)
    catch
    end
    println("Creating screen session \"$(cluster.host_name)\"...")
    run(`screen -L -Logfile remote/$(cluster.host_name)/$(cluster.host_name).log -dmS $(cluster.host_name)`)
    println("Connecting to \"$(cluster.host_name)\"...")
    run(`screen -S $(cluster.host_name) -X stuff "ssh -i $(cluster.identity_file) $(cluster.user)@$(cluster.host_name) \n"`)
    waitForRemote(cluster)
    return nothing
end

function setup(cluster::Cluster)
    println("Creating directory MonitoredQuantumCircuits/...")
    run(`screen -S $(cluster.host_name) -X stuff "mkdir MonitoredQuantumCircuitsENV /dev/null 2>&1; cd MonitoredQuantumCircuitsENV > /dev/null 2>&1\n"`)
    waitForRemote(cluster)
    println("Installing Julia...")
    run(`screen -S $(cluster.host_name) -X stuff "julia --version > /dev/null 2>&1|| curl -fsSL https://install.julialang.org | sh > /dev/null 2>&1\n"`)
    waitForRemote(cluster)
    println("Adding packages...")
    df = DataFrame(CSV.File(".env", delim='=', header=-1))
    row = df[df.Column1.=="GITHUB_USERNAME", :]
    github_username = row.Column2[1]
    row = df[df.Column1.=="GITHUB_PASSWORD", :]
    github_password = row.Column2[1]
    run(`screen -S $(cluster.host_name) -X stuff "julia -e 'using Pkg; Pkg.activate(\".\");Pkg.add(url=\"https://$(github_username):$(github_password)@github.com/J-C-Q/MonitoredQuantumCircuits.jl.git\")'> /dev/null 2>&1\n"`)
    waitForRemote(cluster)
    println("Instantiating packages...")
    run(`screen -S $(cluster.host_name) -X stuff "julia --project -e 'using Pkg; Pkg.instantiate()'> /dev/null 2>&1\n"`)
    waitForRemote(cluster)
    println("Loading python deps...")
    run(`screen -S $(cluster.host_name) -X stuff "julia --project -e 'using MonitoredQuantumCircuits'> /dev/null 2>&1\n"`)
    waitForRemote(cluster)
    run(`screen -S $(cluster.host_name) -X stuff "echo setup done!\n"`)
    waitForRemote(cluster)
    return nothing
end

function upload(cluster::Cluster, file::String)
    println("Uploading file to \"$(cluster.host_name)\"...")
    run(`scp -i $(cluster.identity_file) $(file) $(cluster.user)@$(cluster.host_name):`)
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

# TODO this should to be improved, since intermediate updates will trigger. Good enough for now.
function waitForRemote(cluster::Cluster)
    FileWatching.watch_file("remote/$(cluster.host_name)/$(cluster.host_name).log")
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

function getInfo()


end

function disconnect(cluster::Cluster)
    println("Disconnecting from \"$(cluster.host_name)\"...")
    run(`screen -S $(cluster.host_name) -X quit`)
    return nothing
end
end
