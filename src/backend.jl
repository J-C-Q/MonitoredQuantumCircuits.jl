abstract type Backend end
abstract type Simulator <: Backend end
abstract type QuantumComputer <: Backend end

"""
    isSimulator(backend::Backend)

Return whether the backend is a simulator.
"""
function isSimulator(backend::Backend)
    throw(ArgumentError("Backend $(typeof(backend)) not supported"))
end

function reset! end
