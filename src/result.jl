struct Result{T}
    native_result::T
    measurements::Vector{Tuple{Vector{String},Vector{Int64},Bool}}
    qubit_map_compiled_to_geometry::Vector{Int64}
    qubits_map_geometry_to_compiled::Vector{Int64}
    function Result(native_result::T, circuit::CompiledCircuit) where {T}
        return new{T}(native_result, [], circuit.qubit_map_compiled_to_geometry, circuit.qubits_map_geometry_to_compiled)
    end
end
