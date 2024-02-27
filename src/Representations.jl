abstract type QuantumRegister end

struct LinearRegister <: QuantumRegister
    size::Int64
end

struct HeavyHexagonRegister <: QuantumRegister
    size::Int64
    width::Int64
end

struct GeneralGraphRegister <: QuantumRegister

end

struct IBMQuantumRegister <: QuantumRegister
    name::String
    coupling_map::Vector{NTuple{2,Int64}}
    neighbor_map::Vector{Vector{Int64}}

    function IBMQuantumRegister(device::DeviceInfo)
        coupling_map = [(d[1], d[2]) for d in device.coupling_map]
        neighbors = [Int64[] for _ in 1:device.n_qubits]
        for c in coupling_map
            push!(neighbors[c[1]+1], c[2])
            push!(neighbors[c[2]+1], c[1])
        end
        neighbor_map = [sort!(n) for n in neighbors]
        return new(device.backend_name, coupling_map, neighbor_map)
    end
end



function neighbors(register::LinearRegister, index::Int)
    if register.size <= 1
        return ()
    elseif index == 1
        return (index + 1,)
    elseif index == register.size
        return (index - 1,)
    else
        return (index - 1, index + 1)
    end
end
function neighbors(register::HeavyHexagonRegister)

end
function neighbors(register::GeneralGraphRegister)

end
function neighbors(register::IBMQuantumRegister, index::Int)
    return register.neighbor_map[index+1]
end

abstract type QuantumOperation end
abstract type QuantumGate <: QuantumOperation end

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


abstract type Measurement <: QuantumOperation end

struct ProjectiveMeasurement <: Measurement
end




abstract type QuantumCircuit end

mutable struct GeneralQuantumCircuit <: QuantumCircuit
    gates::Vector{QuantumOperation}
    locations::Vector{AbstractArray{Int64}}
    gatePointer::Vector{Int64}
    register::QuantumRegister
end

struct ClifforCircuit <: QuantumCircuit

end

struct TensorCircuit <: QuantumCircuit

end
