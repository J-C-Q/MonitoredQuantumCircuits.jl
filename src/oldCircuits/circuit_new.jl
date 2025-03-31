abstract type QuantumCircuit end


struct Circuit{T<:Geometry} <: QuantumCircuit
    geometry::T
    operations::Vector{Operation}
    positions::Vector{Tuple{Int,Vararg{Int}}}
    depth::Vector{Int64}
    function Circuit(geometry::Geometry)
        new{typeof(geometry)}(geometry, Operation[], Tuple{Int,Vararg{Int}}[], [1])
    end
    function Circuit(geometry::Geometry, n_operations::Integer)
        new{typeof(geometry)}(
            geometry,
            Vector{Operation}(undef, n_operations),
            Vector{Tuple{Int,Vararg{Int}}}(undef, n_operations),
            [1])
    end
end

function apply!(circuit::Circuit, operation::Operation, position::Vararg{T}) where {T<:Integer}
    _checkInBounds(circuit, operation, position...)
    if length(circuit.operations) < circuit.depth[1]
        push!(circuit.operations, operation)
        push!(circuit.positions, position)
    else
        circuit.operations[circuit.depth[1]] = operation
        circuit.positions[circuit.depth[1]] = position
    end
    circuit.depth[1] += 1
    return nothing
end

function reset!(circuit::Circuit)
    circuit.depth[1] = 1
end

function hard_reset!(circuit::Circuit)
    circuit.operations = Operation[]
    circuit.positions = Tuple{Int,Vararg{Int}}[]
    circuit.depth[1] = 1
end

function depth(circuit::Circuit)
    return circuit.depth[1] - 1
end

function _checkInBounds(circuit::Circuit, operation::Operation, position::Vararg{Integer})
    nQubits(operation) == length(position) || throw(ArgumentError("The number of qubits in the operation does not match the number of qubits in the position."))
    all(1 .<= position .<= nQubits(circuit.geometry)) || throw(ArgumentError("The position is out of bounds."))
end

function execute(::Circuit, backend::Backend; verbose::Bool=true)
    throw(ArgumentError("Backend $(typeof(backend)) not supported"))
end

function nQubits(circuit::Circuit)
    return nQubits(circuit.geometry)
end

function nMeasurement(circuit::Circuit)
    sum = 0
    for i in 1:depth(circuit)
        if typeof(circuit.operations[i]) <: MeasurementOperation
            sum += 1
        end
    end
    return sum
end








# struct RandomCircuit{T<:Geometry} <: QuantumCircuit
#     lattice::T
#     operations::Vector{Operation}
#     time_probability::Vector{Float64}
#     positions::Vector{Vector{Tuple{Int,Vararg{Int}}}}
#     position_probability::Vector{Vector{Float64}}
#     function RandomCircuit(
#         geometry::Geometry,
#         gates::Vector{Operation},
#         probabilities::Vector{Float64},
#         positions::Vector{Vector{Tuple{Int,Vararg{Int}}}})

#         new{typeof(geometry)}(geometry,
#             gates,
#             probabilities,
#             positions,
#             [fill(1 / length(p)) for p in positions])
#     end
# end


# struct FloquetCircuit{T<:Geometry} <: QuantumCircuit

# end
