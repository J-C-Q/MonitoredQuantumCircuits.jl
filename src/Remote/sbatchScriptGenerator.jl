function sbatchScript(;
    account::String="",
    acctg_freq::String="",
    array::String="",
    batch::String="",
    bb::String="",
    bbf::String="",
    start_time::String="",  # Using `start_time` instead of `begin`
    chdir::String="",
    cluster_constraint::String="",
    clusters::String="",
    comment::String="",
    constraint::String="",
    container::String="",
    container_id::String="",
    contiguous::Bool=false,
    core_spec::Int=0,
    cores_per_socket::Int=0,
    cpu_freq::String="",
    cpus_per_gpu::Int=0,
    cpus_per_task::Int=0,
    deadline::String="",
    delay_boot::Int=0,
    dependency::String="",
    distribution::String="",
    error::String="",
    exclude::String="",
    exclusive::String="",
    exports::String="ALL",
    export_file::String="",
    extra::String="",
    extra_node_info::String="",
    get_user_env::String="",
    gid::String="",
    gpu_bind::String="",
    gpu_freq::String="",
    gpus::String="",
    gpus_per_node::String="",
    gpus_per_socket::String="",
    gpus_per_task::String="",
    gres::String="",
    gres_flags::String="",
    help::Bool=false,
    hint::String="",
    hold::Bool=false,
    ignore_pbs::Bool=false,
    input::String="",
    job_name::String="",
    kill_on_invalid_dep::Bool=false,
    licenses::String="",
    mail_type::String="",
    mail_user::String="",
    mcs_label::String="",
    mem::String="",
    mem_bind::String="",
    mem_per_cpu::String="",
    mem_per_gpu::String="",
    mincpus::Int=0,
    network::String="",
    nice::Int=0,
    no_kill::Bool=false,
    no_requeue::Bool=false,
    nodefile::String="",
    nodelist::String="",
    nodes::String="",
    ntasks::Int=1,
    ntasks_per_core::Int=0,
    ntasks_per_gpu::Int=0,
    ntasks_per_node::Int=0,
    ntasks_per_socket::Int=0,
    open_mode::String="truncate",
    output::String="",
    overcommit::Bool=false,
    oversubscribe::Bool=false,
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
    # Build the sbatch command string
    cmd = `sbatch`

    if account != ""
        push!(cmd, "--account=$account")
    end

    if acctg_freq != ""
        push!(cmd, "--acctg-freq=$acctg_freq")
    end

    if array != ""
        push!(cmd, "--array=$array")
    end

    if batch != ""
        push!(cmd, "--batch=$batch")
    end

    if bb != ""
        push!(cmd, "--bb=$bb")
    end

    if bbf != ""
        push!(cmd, "--bbf=$bbf")
    end

    if start_time != ""
        push!(cmd, "--begin=$start_time")
    end

    if chdir != ""
        push!(cmd, "--chdir=$chdir")
    end

    if cluster_constraint != ""
        push!(cmd, "--cluster-constraint=$cluster_constraint")
    end

    if clusters != ""
        push!(cmd, "--clusters=$clusters")
    end

    if comment != ""
        push!(cmd, "--comment=$comment")
    end

    if constraint != ""
        push!(cmd, "--constraint=$constraint")
    end

    if container != ""
        push!(cmd, "--container=$container")
    end

    if container_id != ""
        push!(cmd, "--container-id=$container_id")
    end

    if contiguous
        push!(cmd, "--contiguous")
    end

    if core_spec != 0
        push!(cmd, "--core-spec=$core_spec")
    end

    if cores_per_socket != 0
        push!(cmd, "--cores-per-socket=$cores_per_socket")
    end

    if cpu_freq != ""
        push!(cmd, "--cpu-freq=$cpu_freq")
    end

    if cpus_per_gpu != 0
        push!(cmd, "--cpus-per-gpu=$cpus_per_gpu")
    end

    if cpus_per_task != 0
        push!(cmd, "--cpus-per-task=$cpus_per_task")
    end

    if deadline != ""
        push!(cmd, "--deadline=$deadline")
    end

    if delay_boot != 0
        push!(cmd, "--delay-boot=$delay_boot")
    end

    if dependency != ""
        push!(cmd, "--dependency=$dependency")
    end

    if distribution != ""
        push!(cmd, "--distribution=$distribution")
    end

    if error != ""
        push!(cmd, "--error=$error")
    end

    if exclude != ""
        push!(cmd, "--exclude=$exclude")
    end

    if exclusive != ""
        push!(cmd, "--exclusive=$exclusive")
    end

    if export !=
        "ALL"
        push!(cmd, "--export=$export")
    end

    if export_file != ""
        push!(cmd, "--export-file=$export_file")
    end

    if extra != ""
        push!(cmd, "--extra=$extra")
    end

    if extra_node_info != ""
        push!(cmd, "--extra-node-info=$extra_node_info")
    end

    if get_user_env != ""
        push!(cmd, "--get-user-env=$get_user_env")
    end

    if gid != ""
        push!(cmd, "--gid=$gid")
    end

    if gpu_bind != ""
        push!(cmd, "--gpu-bind=$gpu_bind")
    end

    if gpu_freq != ""
        push!(cmd, "--gpu-freq=$gpu_freq")
    end

    if gpus != ""
        push!(cmd, "--gpus=$gpus")
    end

    if gpus_per_node != ""
        push!(cmd, "--gpus-per-node=$gpus_per_node")
    end

    if gpus_per_socket != ""
        push!(cmd, "--gpus-per-socket=$gpus_per_socket")
    end

    if gpus_per_task != ""
        push!(cmd, "--gpus-per-task=$gpus_per_task")
    end

    if gres != ""
        push!(cmd, "--gres=$gres")
    end

    if gres_flags != ""
        push!(cmd, "--gres-flags=$gres_flags")
    end

    if help
        push!(cmd, "--help")
    end

    if hint != ""
        push!(cmd, "--hint=$hint")
    end

    if hold
        push!(cmd, "--hold")
    end

    if ignore_pbs
        push!(cmd, "--ignore-pbs")
    end

    if input != ""
        push!(cmd, "--input=$input")
    end

    if job_name != ""
        push!(cmd, "--job-name=$job_name")
    end

    if kill_on_invalid_dep
        push!(cmd, "--kill-on-invalid-dep")
    end

    if licenses != ""
        push!(cmd, "--licenses=$licenses")
    end

    if mail_type != ""
        push!(cmd, "--mail-type=$mail_type")
    end

    if mail_user != ""
        push!(cmd, "--mail-user=$mail_user")
    end

    if mcs_label != ""
        push!(cmd, "--mcs-label=$mcs_label")
    end

    if mem != ""
        push!(cmd, "--mem=$mem")
    end

    if mem_bind != ""
        push!(cmd, "--mem-bind=$mem_bind")
    end

    if mem_per_cpu != ""
        push!(cmd, "--mem-per-cpu=$mem_per_cpu")
    end

    if mem_per_gpu != ""
        push!(cmd, "--mem-per-gpu=$mem_per_gpu")
    end

    if mincpus != 0
        push!(cmd, "--mincpus=$mincpus")
    end

    if network != ""
        push!(cmd, "--network=$network")
    end

    if nice != 0
        push!(cmd, "--nice=$nice")
    end

    if no_kill
        push!(cmd, "--no-kill")
    end

    if no_requeue
        push!(cmd, "--no-requeue")
    end

    if nodefile != ""
        push!(cmd, "--nodefile=$nodefile")
    end

    if nodelist != ""
        push!(cmd, "--nodelist=$nodelist")
    end

    if nodes != ""
        push!(cmd, "--nodes=$nodes")
    end

    if ntasks != 1
        push!(cmd, "--ntasks=$ntasks")
    end

    if ntasks_per_core != 0
        push!(cmd, "--ntasks-per-core=$ntasks_per_core")
    end

    if ntasks_per_gpu != 0
        push!(cmd, "--ntasks-per-gpu=$ntasks_per_gpu")
    end

    if ntasks_per_node != 0
        push!(cmd, "--ntasks-per-node=$ntasks_per_node")
    end

    if ntasks_per_socket != 0
        push!(cmd, "--ntasks-per-socket=$ntasks_per_socket")
    end

    if open_mode != "truncate"
        push!(cmd, "--open-mode=$open_mode")
    end

    if output != ""
        push!(cmd, "--output=$output")
    end

    if overcommit
        push!(cmd, "--overcommit")
    end

    if oversubscribe
        push!(cmd, "--oversubscribe")
    end

    if parsable
        push!(cmd, "--parsable")
    end

    if partition != ""
        push!(cmd, "--partition=$partition")
    end

    if prefer != ""
        push!(cmd, "--prefer=$prefer")
    end

    if priority != ""
        push!(cmd, "--priority=$priority")
    end

    if profile != ""
        push!(cmd, "--profile=$profile")
    end

    if propagate != ""
        push!(cmd, "--propagate=$propagate")
    end

    if qos != ""
        push!(cmd, "--qos=$qos")
    end

    if quiet
        push!(cmd, "--quiet")
    end

    if reboot
        push!(cmd, "--reboot")
    end

    if requeue
        push!(cmd, "--requeue")
    end

    if reservation != ""
        push!(cmd, "--reservation=$reservation")
    end

    if resv_ports != 0
        push!(cmd, "--resv-ports=$resv_ports")
    end

    if segment != ""
        push!(cmd, "--segment=$segment")
    end

    if signal != ""
        push!(cmd, "--signal=$signal")
    end

    if sockets_per_node != 0
        push!(cmd, "--sockets-per-node=$sockets_per_node")
    end

    if spread_job
        push!(cmd, "--spread-job")
    end

    if stepmgr
        push!(cmd, "--stepmgr")
    end

    if switches != ""
        push!(cmd, "--switches=$switches")
    end

    if test_only
        push!(cmd, "--test-only")
    end

    if thread_spec != 0
        push!(cmd, "--thread-spec=$thread_spec")
    end

    if threads_per_core != 0
        push!(cmd, "--threads-per-core=$threads_per_core")
    end

    if time != ""
        push!(cmd, "--time=$time")
    end

    if time_min != ""
        push!(cmd, "--time-min=$time_min")
    end

    if tmp != ""
        push!(cmd, "--tmp=$tmp")
    end

    if tres_bind != ""
        push!(cmd, "--tres-bind=$tres_bind")
    end

    if tres_per_task != ""
        push!(cmd, "--tres-per-task=$tres_per_task")
    end

    if uid != ""
        push!(cmd, "--uid=$uid")
    end

    if usage
        push!(cmd, "--usage")
    end

    if use_min_nodes
        push!(cmd, "--use-min-nodes")
    end

    if verbose != 0
        push!(cmd, repeat(["--verbose"], verbose)...)
    end

    if version
        push!(cmd, "--version")
    end

    if wait
        push!(cmd, "--wait")
    end

    if wait_all_nodes != 0
        push!(cmd, "--wait-all-nodes=$wait_all_nodes")
    end

    if wckey != ""
        push!(cmd, "--wckey=$wckey")
    end

    if wrap != ""
        push!(cmd, "--wrap=\"$wrap\"")
    end

    # Execute the sbatch command
    run(cmd)
end
