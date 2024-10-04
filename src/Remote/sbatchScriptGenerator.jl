function sbatchScript(dir::String, name::String, run_file::String;
    nodes=1, ntasks=1, ntasks_per_node=1, cpus_per_task=1, time="1:00:00", partition="normal", account="", email="", output="output.txt", error="error.txt", load_juliaANDmpi_cmd=""
)

    try
        mkpath(dir)
    catch e
    end
    touch(joinpath(dir, "$name.sh"))
    open(joinpath(dir, "$name.sh"), "w") do f
        println(f, "#!/bin/bash")


        account != "" && println(f, "#SBATCH --account=$account")
        println(f, "#SBATCH --time=$time")
        partition != "" && println(f, "#SBATCH --partition=$partition")
        println(f, "#SBATCH --nodes=$nodes")
        println(f, "#SBATCH --ntasks=$ntasks")
        println(f, "#SBATCH --ntasks-per-node=$ntasks_per_node")
        println(f, "#SBATCH --cpus-per-task=$cpus_per_task")
        # println(f, "#SBATCH --mem-per-cpu=$mem_per_cpu")
        email != "" && println(f, "#SBATCH --mail-user=$email")
        email != "" && println(f, "#SBATCH --mail-type=ALL")
        println(f, "#SBATCH --output=$output")
        println(f, "#SBATCH --error=$error")

        println(f, load_juliaANDmpi_cmd)

        println(f, "srun -n $ntasks julia -t $cpus_per_task --project $run_file")

    end
end
