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

abstract type BasisGate <: PreDefGate end

struct GeneralMatrixGate <: QuantumGate
    name::String
    matrix::AbstractMatrix
end

struct PauliX <: BasisGate
    name::String
    matrix::Matrix{Complex{Float16}}
    function PauliX()
        return new("x", [complex(0, 0) complex(1, 0); complex(0, 0) complex(1, 0)])
    end
end

struct Hadamard <: PreDefGate
    name::String
    matrix::Matrix{Complex{Float16}}
    function Hadamard()
        return new("h", [complex(1, 0) complex(1, 0); complex(1, 0) complex(-1, 0)] / sqrt(2))
    end
end


struct ControlledX <: PreDefGate
    name::String
    matrix::Matrix{Complex{Float16}}
    function ControlledX()
        return new(
            "CX",
            [complex(1, 0) complex(0, 0) complex(0, 0) complex(0, 0);
                complex(0, 0) complex(1, 0) complex(0, 0) complex(0, 0);
                complex(0, 0) complex(0, 0) complex(0, 0) complex(1, 0);
                complex(0, 0) complex(0, 0) complex(1, 0) complex(0, 0)]
        )
    end
end





abstract type Measurement <: QuantumOperation end

struct ProjectiveMeasurement <: Measurement
    name::String
    location::Int64
    description::String
    function ProjectiveMeasurement(qubit::Int)
        return new("projM", qubit, "A projective measurement on qubit $qubit.")
    end
end




abstract type QuantumCircuit end

struct GeneralQuantumCircuit <: QuantumCircuit
    operationNames::Vector{String}
    operationDescription::Vector{String}
    qubitsPerOperation::Vector{Int64}
    locations::Vector{Int64}
    parameters::Vector{Float64}
    operationPointer::Vector{Int64}
    locationPointer::Vector{Int64}
    parameterPointer::Vector{Int64}

    """
    Construct a quantum circuit object from a list of operations.
    """
    function GeneralQuantumCircuit(operationList::Vector{QuantumOperation})
        operationNames = String[]
        operationDescription = String[]
        qubitsPerOperation = Int64[]
        locations = Int64[]
        parameters = Float64[]
        operationPointer = Int64[]
        locationPointer = Int64[]
        parameterPointer = Int64[]

        for operation in operationList
            _addOperation!(operation, operationNames, operationDescription, qubitsPerOperation, locations, operationPointer, locationPointer)
        end

    end
end

"""
Add a constant gate to the quantum circuit (only available during construction)
"""
function _addOperation!(operation::BasisGate,
    operationNames::Vector{String},
    operationDescription::Vector{String},
    qubitsPerOperation::Vector{Int64},
    locations::Vector{Int64},
    operationPointer::Vector{Int64},
    locationPointer::Vector{Int64})

    push!(operationNames, operation.name)
    push!(operationDescription, operation.description)
    push!(qubitsPerOperation, 1)
    push!(locations, operation.location)
    push!(operationPointer, length(operationNames))
    push!(locationPointer, length(locations))
end

"""
Add a projective measurement to the quantum circuit (only available during construction)
"""
function _addOperation!(operation::ProjectiveMeasurement,
    operationNames::Vector{String},
    operationDescription::Vector{String},
    qubitsPerOperation::Vector{Int64},
    locations::Vector{Int64},
    operationPointer::Vector{Int64},
    locationPointer::Vector{Int64})

    push!(operationNames, operation.name)
    push!(operationDescription, operation.description)
    push!(qubitsPerOperation, 1)
    push!(locations, operation.location)
    push!(operationPointer, length(operationNames))
    push!(locationPointer, length(locations))
end

struct ClifforCircuit <: QuantumCircuit

end

struct TensorCircuit <: QuantumCircuit

end
