module QiskitInterface
using IBMQClient #https://github.com/QuantumBFS/IBMQClient.jl.git
using IBMQClient.Schema
using JSON

function connect_to_IBMQ(token::String)
    return AccountInfo(token)
end
function connect_to_IBMQ()
    try
        return _get_IBMQ_token()# reading from ~/.qiskit/qiskit-ibm.json
    catch
        error("No IBMQ token found in ~/.qiskit/qiskit-ibm.json. Please provide your API token")
    end
    return nothing
end
function _get_IBMQ_token()
    path = joinpath(homedir(), ".qiskit", "qiskit-ibm.json")
    token = JSON.parsefile(path)["default-ibm-quantum"]["token"]
    return AccountInfo(token)
end
function available_devices(account::AccountInfo)
    devices = IBMQClient.devices(account)

    return IBMQClient.devices(account)
end
function _print_available_devices(account::AccountInfo)
    devices = available_devices(account)
    for device in devices
        println(device.name)
    end
end



end
