module Remote
using CSV
using FileIO
using DataFrames


include("sbatchScriptGenerator.jl")

struct Cluster
    host_name::String
    user::String
    identity_file::String
    ssh_password::String
    remote_password::String
    workingDir::String
    load_juliaANDmpi_cmd::String
    MPI_use_system_binary::Bool
end

"""
    addCluster(user::String, host_name::String, identity_file::String; ssh_password="", remote_password="", workingDir="", load_juliaANDmpi_cmd="", MPI_use_system_binary=true)

Add a cluster to the list of clusters. The cluster will be saved in the file remotes.csv in the current directory. The cluster will be connected to and setup. The cluster will be disconnected after the setup.
"""
function addCluster(user::String, host_name::String, identity_file::String; ssh_password="", remote_password="", workingDir="", load_juliaANDmpi_cmd="", MPI_use_system_binary=true)
    if !isfile("remotes.csv")

        CSV.write("remotes.csv", DataFrame(host_name=[host_name], user=[user], identity_file=[identity_file], ssh_password=[ssh_password], remote_password=[remote_password], workingDir=[workingDir], load_juliaANDmpi_cmd=[load_juliaANDmpi_cmd], MPI_use_system_binary=[MPI_use_system_binary]))

    else
        df = DataFrame(CSV.File("remotes.csv"))

        if isempty(df[df.host_name.==host_name, :])
            push!(df, (host_name, user, identity_file, ssh_password, remote_password, workingDir, load_juliaANDmpi_cmd, MPI_use_system_binary); promote=true)
            CSV.write("remotes.csv", df)
        else
            println("Cluster $(host_name) already exists. Please use loadCluster(\"$host_name\") to load the cluster.")
            return Cluster(host_name, user, identity_file, ssh_password, remote_password, workingDir, load_juliaANDmpi_cmd, MPI_use_system_binary)
        end
    end
    try
        mkpath("remotes/$(host_name)")
    catch
        println("Directory remotes/$(host_name) already exists.")
    end
    cluster = Cluster(host_name, user, identity_file, ssh_password, remote_password, workingDir, load_juliaANDmpi_cmd, MPI_use_system_binary)
    println("Cluster $(host_name) added successfully. Connecting...")
    connect(cluster)
    println("Setting up...")
    setup(cluster)
    println("Disconnecting...")
    disconnect(cluster)
    return cluster
end

"""
    loadCluster(host_name::String)
    loadCluster(id::Integer)

Load a cluster from the list of clusters. The cluster will be loaded from the file remotes.csv in the current directory.
"""
function loadCluster(host_name::String)
    df = DataFrame(CSV.File("remotes.csv"))
    row = df[df.host_name.==host_name, :]
    if isempty(row)
        println("Cluster $(host_name) not found. Run showClusters() to see all clusters.")
        return nothing
    end
    user = row.user[1]
    identity_file = row.identity_file[1]
    ssh_password = row.ssh_password[1]
    remote_password = row.remote_password[1]
    workingDir = row.workingDir[1]
    load_juliaANDmpi_cmd = row.load_juliaANDmpi_cmd[1]
    MPI_use_system_binary = row.MPI_use_system_binary[1]
    if password === missing
        return Cluster(host_name, user, identity_file, "", "", workingDir, load_juliaANDmpi_cmd, MPI_use_system_binary)
    else
        return Cluster(host_name, user, identity_file, ssh_password, remote_password, workingDir, load_juliaANDmpi_cmd, MPI_use_system_binary)
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
    ssh_password = row.ssh_password
    remote_password = row.remote_password
    workingDir = row.workingDir
    load_juliaANDmpi_cmd = row.load_juliaANDmpi_cmd
    MPI_use_system_binary = row.MPI_use_system_binary
    if ssh_password === missing
        return Cluster(host_name, user, identity_file, "", "", workingDir, load_juliaANDmpi_cmd, MPI_use_system_binary)
    else
        return Cluster(host_name, user, identity_file, ssh_password, remote_password, workingDir, load_juliaANDmpi_cmd, MPI_use_system_binary)
    end
end

"""
    showClusters()

Show all clusters that have been added.
"""
function showClusters()
    if !isfile("remotes.csv")
        println("No clusters added.")
        return nothing
    else
        df = DataFrame(CSV.File("remotes.csv"))
        return df
    end
end

"""
    connect(cluster::Cluster)

Connect to the cluster.
"""

function connect(cluster::Cluster)
    run(`ssh -fN -M -S remotes/ssh_mux_%h_%p_%r -i $(cluster.identity_file) $(cluster.user)@$(cluster.host_name)`)
    return nothing
end


function setup(cluster::Cluster)

    if !isfile(".env")
        println("No .env file found. Please create a .env file with the following format:")
        println("GITHUB_USERNAME=<username>")
        println("GITHUB_PASSWORD=<accesstoken>")
        return nothing
    end

    mkdir(cluster, joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV"))

    upload(cluster, joinpath(@__DIR__, "execScript.jl"), joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV"))

    println("Adding packages...")
    df = DataFrame(CSV.File(".env", delim='=', header=-1))
    row = df[df.Column1.=="GITHUB_USERNAME", :]
    github_username = row.Column2[1]
    row = df[df.Column1.=="GITHUB_PASSWORD", :]
    github_password = row.Column2[1]

    runCommand(cluster, [
            "$(cluster.load_juliaANDmpi_cmd)",
            "julia -e 'using Pkg;Pkg.activate(\".\");Pkg.add(PackageSpec(url=\"https://$(github_username):$(github_password)@github.com/J-C-Q/MonitoredQuantumCircuits.jl.git\", rev=\"main\")); Pkg.add(\"JLD2\"); Pkg.add(\"MPI\")'",
            "julia --project -e 'using Pkg; Pkg.instantiate()'",
            "julia --project -e 'using Pkg;Pkg.add(PackageSpec(url=\"https://github.com/J-C-Q/CondaPkg.jl.git\", rev=\"main\"));'",
            "julia --project -e 'using MonitoredQuantumCircuits'"],
        at=joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV"))


    if cluster.MPI_use_system_binary
        runCommand(cluster, [
                "$(cluster.load_juliaANDmpi_cmd)",
                "julia --project -e 'using MPI.MPIPreferences; MPIPreferences.use_system_binary()'"];
            at=joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV"))
    end
    return nothing
end

function upload(cluster::Cluster, file::String, destination::String="")
    run(`scp -o 'ControlPath remotes/ssh_mux_%h_%p_%r' -i $(cluster.identity_file) $(file) $(cluster.user)@$(cluster.host_name):$(destination)`)
end

function refreshFiles(cluster::Cluster, directory::String)
    # This is usefull if files in the working directory will be deleated after some time (relative to the modification date)
    output = runCommand(cluster, "find $(cluster.workingDir)/$(directory) -type f -exec touch {} ;")
    return output
end

function mkdir(cluster::Cluster, directory::String)
    output = runCommand(cluster, "mkdir -p $(directory)")
    return output
end

"""
    getQueue(cluster::Cluster)

Get your queued jobs on the cluster (i.e. squeue -u).
"""
function getQueue(cluster::Cluster)
    output = runCommand(cluster, "squeue -u $(cluster.user)")
    return toDataframe(output)
end

function toDataframe(string::String)
    # Create an IOBuffer from the CSV data string
    io = IOBuffer(string)
    # Use CSV.read to parse the data into a DataFrame
    df = CSV.read(io, DataFrame, delim=' ', ignorerepeated=true, header=1)
    return df
end

function runCommand(cluster::Cluster, command::String; at=".")
    output = read(`ssh -S remotes/ssh_mux_%h_%p_%r -i $(cluster.identity_file) $(cluster.user)@$(cluster.host_name) "cd $at;$(command)"`, String)
    return output
end

function runCommand(cluster::Cluster, command::Vector{String}; at=".")
    output = read(`ssh -S remotes/ssh_mux_%h_%p_%r -i $(cluster.identity_file) $(cluster.user)@$(cluster.host_name) $(join(["cd $at",join(command,";")],";"))`, String)
    return output
end


function queueJob(cluster::Cluster, bashFile::String, path::String)
    output = runCommand(cluster, "sbatch $(bashFile)"; at=joinpath("$(cluster.workingDir)", "$(path)"))
    return output
end

"""
    downloadResults(cluster::Cluster, id::String; destination::String=".")

Download the results of a job with the id `id` from the cluster.
"""
function downloadResults(cluster::Cluster, id::String; destination::String=".")
    path = joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV", "$(id)")
    println("Preparing for download...")
    print(runCommand(cluster, ["cd $path", "zip -0 -r $(id).zip data/"]))
    run(`scp -o 'ControlPath remotes/ssh_mux_%h_%p_%r' -i $(cluster.identity_file) $(cluster.user)@$(cluster.host_name):$(joinpath("$path","$(id).zip")) $(destination)`)
    # run(`unzip $(joinpath("$destination","$(id).zip"))`)
    return nothing
end

function downloadResults2(cluster::Cluster, id::String; destination::String=".")
    path = joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV", "$(id)")
    # println("Preparing for download...")
    # print(runCommand(cluster, ["cd $path", "zip -r -0 $(id).zip data/"]))
    run(`scp -r -o 'ControlPath remotes/ssh_mux_%h_%p_%r' -i $(cluster.identity_file) $(cluster.user)@$(cluster.host_name):$(joinpath("$path","data")) $(destination)`)
    # run(`unzip $(joinpath("$destination","$(id).zip"))`)
    return nothing
end

function downloadResultsRsync(cluster::Cluster, id::String; destination::String=".")
    path = joinpath("$(cluster.workingDir)", "MonitoredQuantumCircuitsENV", "$(id)")
    println("Preparing for download...")


    print(runCommand(cluster, ["cd $path", "zip -0 -r $(id).zip data/"]))
    run(`scp -o 'ControlPath remotes/ssh_mux_%h_%p_%r' -i $(cluster.identity_file) $(cluster.user)@$(cluster.host_name):$(joinpath("$path","$(id).zip")) $(destination)`)
    # run(`unzip $(joinpath("$destination","$(id).zip"))`)
    return nothing
end

function hostname(cluster::Cluster)
    runCommand(cluster, "hostname")
end


function getInfo()


end

"""
    disconnect(cluster::Cluster)

Disconnect from the cluster.
"""
function disconnect(cluster::Cluster)
    run(`ssh -S remotes/ssh_mux_%h_%p_%r -i $(cluster.identity_file) $(cluster.user)@$(cluster.host_name) -O exit`)
    return nothing
end


end
