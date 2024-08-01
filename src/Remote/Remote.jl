module Remote

export Cluster
export addCluster
export connect

struct Cluster
    host_name::String
    user::String
    identity_file::String
    password::String
end

# TODO add cluster to file, maybe csv
function addCluster(user::String, host_name::String, identity_file::String)
    Cluster(host_name, user, identity_file, "")
end

function connect(cluster::Cluster)
    # TODO
    println("Creating screen session \"$(cluster.host_name)\"...")
    run(`screen -L -Logfile $(cluster.host_name).log -dmS $(cluster.host_name)`)
    println("Connecting to \"$(cluster.host_name)\"...")
    run(`screen -S $(cluster.host_name) -X stuff "ssh -i $(cluster.identity_file) $(cluster.user)@$(cluster.host_name) \n"`)
end

function upload(cluster::Cluster, file::String)
    println("Uploading file to \"$(cluster.host_name)\"...")
    run(`scp -i $(cluster.identity_file) $(file) $(cluster.user)@$(cluster.host_name):`)
end

function getQueue(cluster::Cluster)
    println("Getting queue from \"$(cluster.host_name)\"...")
    line1 = open("$(cluster.host_name).log", "r") do file
        countlines(file)
    end
    run(`screen -S $(cluster.host_name) -X stuff "squeue -u $(cluster.user)\n"`)
    line2 = 0
    for _ in 1:10
        line2 = open("$(cluster.host_name).log", "r") do file
            countlines(file)
        end
        if line2 > line1
            break
        end
        sleep(2)
    end

    nlines = line2 - line1
    println("Queue:")
    lines = open("$(cluster.host_name).log", "r") do file
        last(eachline(file), nlines)
    end
    for line in lines[1:end-1]
        println(line)
    end
    return nothing
end

function getInfo()


end

function disconnect(cluster::Cluster)
    println("Disconnecting from \"$(cluster.host_name)\"...")
    run(`screen -S $(cluster.host_name) -X quit`)
    return nothing
end
end
