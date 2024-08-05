function sbatchScript(dir::Sting, name::String, run_file::String, use_mpi=false;
    account::String="",
    array::String="",
    batch::String="",
    start_time::String="",  # Using `start_time` instead of `begin`
    chdir::String="",
    comment::String="",
    constraint::String="",
    contiguous::Bool=false,
    cores_per_socket::Int=0,
    cpus_per_gpu::Int=0,
    cpus_per_task::Int=0,
    deadline::String="",
    distribution::String="",
    error::String="",
    exclude::String="",
    exclusive::String="",
    exports::String="ALL", # Using `exports` instead of `export`
    extra::String="",
    extra_node_info::String="",
    gpu_bind::String="",
    gpus::String="",
    gpus_per_node::String="",
    gpus_per_socket::String="",
    gpus_per_task::String="",
    gres::String="",
    gres_flags::String="",
    hint::String="",
    input::String="",
    job_name::String="",
    mail_type::String="",
    mail_user::String="",
    mem::String="",
    mem_bind::String="",
    mem_per_cpu::String="",
    mem_per_gpu::String="",
    mincpus::Int=0,
    nodes::String="",
    ntasks::Int=1,
    ntasks_per_core::Int=0,
    ntasks_per_gpu::Int=0,
    ntasks_per_node::Int=0,
    ntasks_per_socket::Int=0,
    output::String="",
    parsable::Bool=false,
    partition::String="",
    prefer::String="",
    priority::String="",
    profile::String="",
    propagate::String="",
    qos::String="",
    quiet::Bool=false,
    reboot::Bool=false,
    requeue::Bool=false,
    reservation::String="",
    resv_ports::Int=0,
    segment::String="",
    signal::String="",
    sockets_per_node::Int=0,
    spread_job::Bool=false,
    stepmgr::Bool=false,
    switches::String="",
    test_only::Bool=false,
    thread_spec::Int=0,
    threads_per_core::Int=0,
    time::String="",
    time_min::String="",
    tmp::String="",
    tres_bind::String="",
    tres_per_task::String="",
    uid::String="",
    usage::Bool=false,
    use_min_nodes::Bool=false,
    verbose::Int=0,
    version::Bool=false,
    wait::Bool=false,
    wait_all_nodes::Int=0,
    wckey::String="",
    wrap::String=""
)

    try
        mkpath(dir)
    catch e
    end
    open(joinpath(dir, "$name.sh"), create=true) do f
        println(f, "#!/bin/bash")

        #!
        if account != ""
            println(f, "--account=$account")
        end

        if acctg_freq != ""
            println(f, "--acctg-freq=$acctg_freq")
        end

        if array != ""
            println(f, "--array=$array")
        end

        if batch != ""
            println(f, "--batch=$batch")
        end

        if bb != ""
            println(f, "--bb=$bb")
        end

        if bbf != ""
            println(f, "--bbf=$bbf")
        end

        if start_time != ""
            println(f, "--begin=$start_time")
        end

        #!
        if chdir != ""
            println(f, "--chdir=$chdir")
        end

        if cluster_constraint != ""
            println(f, "--cluster-constraint=$cluster_constraint")
        end

        if clusters != ""
            println(f, "--clusters=$clusters")
        end

        if comment != ""
            println(f, "--comment=$comment")
        end

        if constraint != ""
            println(f, "--constraint=$constraint")
        end

        if container != ""
            println(f, "--container=$container")
        end

        if container_id != ""
            println(f, "--container-id=$container_id")
        end

        if contiguous
            println(f, "--contiguous")
        end

        if core_spec != 0
            println(f, "--core-spec=$core_spec")
        end

        if cores_per_socket != 0
            println(f, "--cores-per-socket=$cores_per_socket")
        end

        if cpu_freq != ""
            println(f, "--cpu-freq=$cpu_freq")
        end

        if cpus_per_gpu != 0
            println(f, "--cpus-per-gpu=$cpus_per_gpu")
        end

        if cpus_per_task != 0
            println(f, "--cpus-per-task=$cpus_per_task")
        end

        if deadline != ""
            println(f, "--deadline=$deadline")
        end

        if delay_boot != 0
            println(f, "--delay-boot=$delay_boot")
        end

        if dependency != ""
            println(f, "--dependency=$dependency")
        end

        if distribution != ""
            println(f, "--distribution=$distribution")
        end

        if error != ""
            println(f, "--error=$error")
        end

        if exclude != ""
            println(f, "--exclude=$exclude")
        end

        if exclusive != ""
            println(f, "--exclusive=$exclusive")
        end

        if exports !=
           "ALL"
            println(f, "--export=$export")
        end

        if export_file != ""
            println(f, "--export-file=$export_file")
        end

        if extra != ""
            println(f, "--extra=$extra")
        end

        if extra_node_info != ""
            println(f, "--extra-node-info=$extra_node_info")
        end

        if get_user_env != ""
            println(f, "--get-user-env=$get_user_env")
        end

        if gid != ""
            println(f, "--gid=$gid")
        end

        if gpu_bind != ""
            println(f, "--gpu-bind=$gpu_bind")
        end

        if gpu_freq != ""
            println(f, "--gpu-freq=$gpu_freq")
        end

        if gpus != ""
            println(f, "--gpus=$gpus")
        end

        if gpus_per_node != ""
            println(f, "--gpus-per-node=$gpus_per_node")
        end

        if gpus_per_socket != ""
            println(f, "--gpus-per-socket=$gpus_per_socket")
        end

        if gpus_per_task != ""
            println(f, "--gpus-per-task=$gpus_per_task")
        end

        if gres != ""
            println(f, "--gres=$gres")
        end

        if gres_flags != ""
            println(f, "--gres-flags=$gres_flags")
        end

        if help
            println(f, "--help")
        end

        if hint != ""
            println(f, "--hint=$hint")
        end

        if hold
            println(f, "--hold")
        end

        if ignore_pbs
            println(f, "--ignore-pbs")
        end

        if input != ""
            println(f, "--input=$input")
        end

        if job_name != ""
            println(f, "--job-name=$job_name")
        end

        if kill_on_invalid_dep
            println(f, "--kill-on-invalid-dep")
        end

        if licenses != ""
            println(f, "--licenses=$licenses")
        end

        if mail_type != ""
            println(f, "--mail-type=$mail_type")
        end

        if mail_user != ""
            println(f, "--mail-user=$mail_user")
        end

        if mcs_label != ""
            println(f, "--mcs-label=$mcs_label")
        end

        if mem != ""
            println(f, "--mem=$mem")
        end

        if mem_bind != ""
            println(f, "--mem-bind=$mem_bind")
        end

        if mem_per_cpu != ""
            println(f, "--mem-per-cpu=$mem_per_cpu")
        end

        if mem_per_gpu != ""
            println(f, "--mem-per-gpu=$mem_per_gpu")
        end

        if mincpus != 0
            println(f, "--mincpus=$mincpus")
        end

        if network != ""
            println(f, "--network=$network")
        end

        if nice != 0
            println(f, "--nice=$nice")
        end

        if no_kill
            println(f, "--no-kill")
        end

        if no_requeue
            println(f, "--no-requeue")
        end

        if nodefile != ""
            println(f, "--nodefile=$nodefile")
        end

        if nodelist != ""
            println(f, "--nodelist=$nodelist")
        end

        if nodes != ""
            println(f, "--nodes=$nodes")
        end

        if ntasks != 1
            println(f, "--ntasks=$ntasks")
        end

        if ntasks_per_core != 0
            println(f, "--ntasks-per-core=$ntasks_per_core")
        end

        if ntasks_per_gpu != 0
            println(f, "--ntasks-per-gpu=$ntasks_per_gpu")
        end

        if ntasks_per_node != 0
            println(f, "--ntasks-per-node=$ntasks_per_node")
        end

        if ntasks_per_socket != 0
            println(f, "--ntasks-per-socket=$ntasks_per_socket")
        end

        if open_mode != "truncate"
            println(f, "--open-mode=$open_mode")
        end

        if output != ""
            println(f, "--output=$output")
        end

        if overcommit
            println(f, "--overcommit")
        end

        if oversubscribe
            println(f, "--oversubscribe")
        end

        if parsable
            println(f, "--parsable")
        end

        if partition != ""
            println(f, "--partition=$partition")
        end

        if prefer != ""
            println(f, "--prefer=$prefer")
        end

        if priority != ""
            println(f, "--priority=$priority")
        end

        if profile != ""
            println(f, "--profile=$profile")
        end

        if propagate != ""
            println(f, "--propagate=$propagate")
        end

        if qos != ""
            println(f, "--qos=$qos")
        end

        if quiet
            println(f, "--quiet")
        end

        if reboot
            println(f, "--reboot")
        end

        if requeue
            println(f, "--requeue")
        end

        if reservation != ""
            println(f, "--reservation=$reservation")
        end

        if resv_ports != 0
            println(f, "--resv-ports=$resv_ports")
        end

        if segment != ""
            println(f, "--segment=$segment")
        end

        if signal != ""
            println(f, "--signal=$signal")
        end

        if sockets_per_node != 0
            println(f, "--sockets-per-node=$sockets_per_node")
        end

        if spread_job
            println(f, "--spread-job")
        end

        if stepmgr
            println(f, "--stepmgr")
        end

        if switches != ""
            println(f, "--switches=$switches")
        end

        if test_only
            println(f, "--test-only")
        end

        if thread_spec != 0
            println(f, "--thread-spec=$thread_spec")
        end

        if threads_per_core != 0
            println(f, "--threads-per-core=$threads_per_core")
        end

        if time != ""
            println(f, "--time=$time")
        end

        if time_min != ""
            println(f, "--time-min=$time_min")
        end

        if tmp != ""
            println(f, "--tmp=$tmp")
        end

        if tres_bind != ""
            println(f, "--tres-bind=$tres_bind")
        end

        if tres_per_task != ""
            println(f, "--tres-per-task=$tres_per_task")
        end

        if uid != ""
            println(f, "--uid=$uid")
        end

        if usage
            println(f, "--usage")
        end

        if use_min_nodes
            println(f, "--use-min-nodes")
        end

        if verbose != 0
            println(f, repeat(["--verbose"], verbose)...)
        end

        if version
            println(f, "--version")
        end

        if wait
            println(f, "--wait")
        end

        if wait_all_nodes != 0
            println(f, "--wait-all-nodes=$wait_all_nodes")
        end

        if wckey != ""
            println(f, "--wckey=$wckey")
        end

        if wrap != ""
            println(f, "--wrap=\"$wrap\"")
        end
    end
    # Execute the sbatch command
    run(cmd)
end
