

function IBMQrun(qobj, deviceName, token)
    account = AccountInfo(token)
    validate_backend(deviceName, account) || throw("No IBMQ backend with name $deviceName.")
    job_info = IBMQClient.submit(account, RemoteJob(dev=deviceName), qobj)
    println("Job started with id $(job_info.id)")
end

function IBMQjobs(token)
    account = AccountInfo(token)
    return IBMQClient.jobs(account)
end

function IBMQdevices(token)
    account = AccountInfo(token)
    devices = IBMQClient.devices(account)
    names = [d.backend_name for d in devices]
    println(names)
    return devices
end

function validate_backend(deviceName::String, account::AccountInfo)
    return deviceName in [d.backend_name for d in IBMQClient.devices(account)]
end
