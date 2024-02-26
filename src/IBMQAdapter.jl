

function IBMQrun(qobj, deviceName)
    validate_backend(deviceName) || throw("No IBMQ backend with name $deviceName.")
    job_info = IBMQClient.submit(IBMQ_ACCOUNT, RemoteJob(dev=deviceName), qobj)
    println("Job started with id $(job_info.id)")
end

function IBMQstatus(id::String)
    jobAPI = IBMQClient.JobAPI(IBMQ_ACCOUNT.project, id)
    IBMQClient.status(IBMQ_ACCOUNT,)
end

function validate_backend(deviceName::String)
    return deviceName in [d.backend_name for d in IBMQClient.devices(IBMQ_ACCOUNT)]
end

function activateAccount(token::String)
    global IBMQ_ACCOUNT = AccountInfo(token)
end
