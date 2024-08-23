function sbatchScript(dir::String, name::String, run_file::String, use_mpi=false;
    nodes=1, ntasks=1, cpus_per_task=1, mem_per_cpu="1G", time="1:00:00", partition="normal", account=""
)

    try
        mkpath(dir)
    catch e
    end
    open(joinpath(dir, "$name.sh"), create=true) do f
        println(f, "#!/bin/bash")

        println(f, "--account=$account")
        println(f, "--time=$time")
        println(f, "--partition=$partition")
        println(f, "--nodes=$nodes")
        println(f, "--ntasks=$ntasks")
        println(f, "--cpus-per-task=$cpus_per_task")
        println(f, "--mem-per-cpu=$mem_per_cpu")

        if use_mpi
            println(f, "module load mpi")
            println(f, "mpirun -np $ntasks julia --project $run_file")
        else
            println(f, "julia --project $run_file")
        end

    end
end
