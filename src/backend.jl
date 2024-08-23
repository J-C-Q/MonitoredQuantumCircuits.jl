abstract type Backend end
abstract type Simulator <: Backend end
abstract type QuantumComputer <: Backend end

function isSimulator(backend::Backend)
    throw(ArgumentError("Backend $(typeof(backend)) not supported"))
end
