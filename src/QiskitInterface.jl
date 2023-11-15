module QiskitInterface

function _check_for_IBMQ_token()
    IBMQ_token = ""
    if !isfile(".env")
        error("No .env file found. Please create one with your IBMQ token.")
    else
        IBMQ_token = _retrieve__IMBQ_token_from(".env")
    end
    return IBMQ_token
end

function _retrieve__IMBQ_token_from(filePath::String)
    IBMQ_token = ""
    for line in readlines(filePath)
        if occursin("IBMQ_TOKEN", line)
            IBMQ_token = split(line, "=")[2]
        end
    end

    if IBMQ_token == ""
        error("Empty IBMQ token in .env file.")
    else
        return IBMQ_token
    end
end

end
