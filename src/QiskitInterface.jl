module QiskitInterface
using IBMQClient #https://github.com/QuantumBFS/IBMQClient.jl.git
using IBMQClient.Schema

function connenct_to_IBMQ(token::String)
    return AccountInfo(token)
end
function connenct_to_IBMQ()
    try
        account = AccountInfo() # reading from ~/.qiskit/.qiskitrc
    catch
        error("No IBMQ token found in ~/.qiskit/.qiskitrc. Please run AccountInfo(\"<your token>\")")
    end
    return account
end
function available_devices(account::AccountInfo)
    return devices(account)
end



end
