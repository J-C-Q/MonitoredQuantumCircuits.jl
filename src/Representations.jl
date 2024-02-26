abstract type QuantumRegister end

struct LinearRegister <: QuantumRegister
    size::Int64
end

struct HeavyHexagonRegister <: QuantumRegister

end

struct GeneralGraphRegister <: QuantumRegister

end


function neighbors(register::LinearRegister, index::Int)
    if register.size <= 1
        return []
    elseif index == 1
        return [index + 1]
    elseif index == register.size
        return [index - 1]
    else
        return [index - 1, index + 1]
    end
end
function neighbors(register::HeavyHexagonRegister)

end
function neighbors(register::GeneralGraphRegister)

end

abstract type QuantumGate end

abstract type PreDefGate <: QuantumGate end

struct GeneralMatrixGate <: QuantumGate
    name::String
    matrix::AbstractMatrix
end

struct PauliX <: PreDefGate
    name::String
    matrix::Matrix{Complex{Float16}}
    function PauliX()
        return new("x", [complex(0, 0) complex(1, 0); complex(0, 0) complex(1, 0)])
    end
end

struct PauliY <: PreDefGate

end

struct PauliZ <: PreDefGate

end





abstract type QuantumCircuit end

mutable struct GeneralQuantumCircuit <: QuantumCircuit
    gates::Vector{QuantumGate}
    locations::Vector{AbstractArray{Int64}}
    gatePointer::Vector{Int64}
    register::QuantumRegister
end

struct ClifforCircuit <: QuantumCircuit

end

struct TensorCircuit <: QuantumCircuit

end
