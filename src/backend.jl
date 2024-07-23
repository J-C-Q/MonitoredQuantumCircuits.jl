abstract type Backend end

function isSimulator(backend::Backend)
    throw(ArgumentError("Backend $(typeof(backend)) not supported"))
end
