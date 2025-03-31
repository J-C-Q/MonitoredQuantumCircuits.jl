function _print_human_readable(size_bytes::Csize_t)
    size_mb = size_bytes / (1024^2)  # Convert to MB
    size_gb = size_bytes / (1024^3)  # Convert to GB

    if size_gb >= 1
        println("Workspace size: ", size_gb, "GB")
    elseif size_mb >= 1
        println("Workspace size: ", size_mb, "MB")
    else
        println("Workspace size: ", size_bytes / 1024, "KB")
    end
end
