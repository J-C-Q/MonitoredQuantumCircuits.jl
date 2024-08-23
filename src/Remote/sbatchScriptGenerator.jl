function sbatchScript(dir::String, name::String, run_file::String; use_mpi=false,
    nodes=1, ntasks=1, cpus_per_task=1, mem_per_cpu="1G", time="1:00:00", partition="normal", account=""
)

    try
        mkpath(dir)
    catch e
    end
    touch(joinpath(dir, "$name.sh"))
    open(joinpath(dir, "$name.sh"),"w") do f
        println(f, "#!/bin/bash")

        println(f, "#SBATCH --account=$account")
        println(f, "#SBATCH --time=$time")
        println(f, "#SBATCH --partition=$partition")
        println(f, "#SBATCH --nodes=$nodes")
        println(f, "#SBATCH --ntasks=$ntasks")
        println(f, "#SBATCH --cpus-per-task=$cpus_per_task")
        println(f, "#SBATCH --mem-per-cpu=$mem_per_cpu")

        if use_mpi
            println(f, "module load mpi")
            println(f, "srun mpirun -np $ntasks julia --project $run_file")
        else
            println(f, "srun julia --project $run_file")
        end

    end
end
