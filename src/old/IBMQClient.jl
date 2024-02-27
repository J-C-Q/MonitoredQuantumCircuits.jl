function createAccount(api_token)
    IBMQAccount = IBMQClient.AccountInfo(api_token)
    jldsave("env.jld2"; IBMQAccount)
    # write(joinpath(pwd(), ".env"), "IBMQ_API_TOKEN=$api_token")
end

function IBMQ_simulate(quantumCircuit::AbstractBlock{N}, description::String) where {N}
    header = Dict("description" => description)
    qobj = YaoBlocksQobj.convert_to_qobj([quantumCircuit], id="test_id", header=header)
    account = load("env.jld2", "IBMQ_account")
    println(account)
    # job_info = IBMQClient.submit(account, RemoteJob(dev="ibmq_qasm_simulator"), qobj)
end
