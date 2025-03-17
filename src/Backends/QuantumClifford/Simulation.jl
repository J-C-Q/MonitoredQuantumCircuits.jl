"""
    TableauSimulator(qubits::Integer; mixed=true, basis=:Z)
    TableauSimulator(initial_state::QuantumClifford.MixedDestabilizer)

A QuantumClifford stabilizer simulator.
"""
struct TableauSimulator <: MonitoredQuantumCircuits.Simulator
    initial_state::QC.MixedDestabilizer{QC.Tableau{Vector{UInt8},Matrix{UInt64}}}
    pauli_operator::QC.PauliOperator{Array{UInt8,0},Vector{UInt64}}
    function TableauSimulator(qubits::Integer; mixed=true, basis=:Z)
        if mixed
            new(QC.MixedDestabilizer(zero(QC.Stabilizer, qubits)), QC.zero(QC.PauliOperator, qubits))
        else
            new(QC.MixedDestabilizer(one(QC.Stabilizer, qubits; basis)), QC.zero(QC.PauliOperator, qubits))
        end
    end
    function TableauSimulator(initial_state::QC.MixedDestabilizer)
        new(initial_state, QC.zero(QC.PauliOperator, initial_state.tab.nqubits))
    end
end
function setInitialState(sim::TableauSimulator, state::QC.MixedDestabilizer)
    sim.initial_state.tab.phases .= state.tab.phases
    sim.initial_state.tab.xzs .= state.tab.xzs
    sim.initial_state.rank = state.rank
end

"""
    PauliFrameSimulator()

A QuantumClifford stabilizer Pauli frame simulator.
"""
struct PauliFrameSimulator <: MonitoredQuantumCircuits.Simulator
end

"""
    GPUPauliFrameSimulator()

A QuantumClifford stabilizer Pauli frame simulator that runs on the GPU.
"""
struct GPUPauliFrameSimulator <: MonitoredQuantumCircuits.Simulator
end
using AllocCheck

function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, simulator::TableauSimulator; keep_result::Bool=false)
    state = simulator.initial_state
    for i in 1:MonitoredQuantumCircuits.depth(circuit)
        operation, position = circuit[i]
        apply!(state, simulator, MonitoredQuantumCircuits.getOperationByIndex(circuit, operation), position; keep_result)
    end
    return state
end

function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.CircuitConstructor, simulator::TableauSimulator; keep_result::Bool=false)
    state = simulator.initial_state
    for i in 1:MonitoredQuantumCircuits.depth(circuit)
        operation, position = circuit[i]
        apply!(state, simulator, operation, position; keep_result)
    end
    return state
end





# function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit, simulator::TableauSimulator; keep_result=false)
#     state = simulator.initial_state

#     for i in eachindex(1:MonitoredQuantumCircuits.depth(circuit))
#         apply!(state, simulator, circuit.operations[i], circuit.positions[i]...; keep_result)
#     end

#     return state
# end

# struct ApplyData
#     type::Int64
#     floatParameter::SubArray{Float64,1,Vector{Float64},Tuple{UnitRange{UInt64}},true}
#     intParamter::SubArray{Int64,1,Vector{Int64},Tuple{UnitRange{UInt64}},true}
#     position::SubArray{Int64,1,Vector{Int64},Tuple{UnitRange{UInt64}},true}
# end

# function MonitoredQuantumCircuits.execute(circuit::MonitoredQuantumCircuits.Circuit2,
#     simulator::TableauSimulator; keep_result=false)

#     for i in eachindex(1:MonitoredQuantumCircuits.depth(circuit))
#         randomness = circuit.pointerMemory[i].randomness

#         if randomness == 0
#             data = _apply_notRandom!(circuit, i)
#         elseif randomness == 1
#             data = _apply_randomType!(circuit, i)
#         elseif randomness == 2
#             data = _apply_randomPos!(circuit, i)
#         elseif randomness == 3
#             data = _apply_fullyRandom!(circuit, i)
#         end
#         dispatch_apply(data, simulator, keep_result)
#     end

#     return simulator.initial_state
# end

# function _apply_notRandom!(circuit::MonitoredQuantumCircuits.Circuit2, i::Int64)
#     pointers = circuit.pointerMemory[i]
#     type = circuit.typeMemory[pointers.typeOffset]
#     qubits = circuit.positionLengthMemory[pointers.positionLengthOffset]
#     position = @view circuit.positionMemory[pointers.positionOffset:pointers.positionOffset+qubits-1]
#     nfloatParamters = circuit.floatParameterLengthMemory[pointers.floatParameterLengthOffset]
#     floatParameter = @view circuit.floatParameterMemory[pointers.floatParameterOffset:pointers.floatParameterOffset+nfloatParamters-1]
#     nintParamters = circuit.intParameterLengthMemory[pointers.intParameterLengthOffset]
#     intParameter = @view circuit.intParameterMemory[pointers.intParameterOffset:pointers.intParameterOffset+nintParamters-1]

#     return ApplyData(type, floatParameter, intParameter, position)
# end

# function _apply_randomType!(circuit::MonitoredQuantumCircuits.Circuit2, i::Int64)
#     pointers = circuit.pointerMemory[i]
#     typeIndex = sample(circuit.typeProbabilityMemory[pointers.typeProbabilityOffset])
#     type = circuit.typeMemory[pointers.typeOffset+typeIndex-1]
#     qubits = circuit.positionLengthMemory[pointers.positionLengthOffset+typeIndex-1]

#     # only random type
#     position = @view circuit.positionMemory[pointers.positionOffset:pointers.positionOffset+qubits-1]

#     offset = pointers.floatParameterOffset
#     for j in 1:typeIndex-1
#         offset += circuit.floatParameterLengthMemory[pointers.floatParameterLengthOffset+j]
#     end
#     nfloatParamters = circuit.floatParameterLengthMemory[pointers.floatParameterLengthOffset+typeIndex-1]
#     floatParameter = @view circuit.floatParameterMemory[offset:offset+nfloatParamters-1]

#     offset = pointers.intParameterOffset
#     for j in 1:typeIndex-1
#         offset += circuit.intParameterLengthMemory[pointers.intParameterLengthOffset+j]
#     end
#     nintParamters = circuit.intParameterLengthMemory[pointers.intParameterLengthOffset+typeIndex-1]
#     intParameter = @view circuit.intParameterMemory[offset:offset+nintParamters-1]

#     return ApplyData(type, floatParameter, intParameter, position)
# end

# function _apply_randomPos!(circuit::MonitoredQuantumCircuits.Circuit2, i::Int64)
#     pointers = circuit.pointerMemory[i]
#     type = circuit.typeMemory[pointers.typeOffset]
#     positionIndex = sample(circuit.positionProbabilityMemory[pointer.positionProbabilityOffset])
#     qubits = circuit.positionLengthMemory[pointers.positionLengthOffset]
#     offset = pointers.positionOffset + (positionIndex - 1) * qubits
#     position = @view circuit.positionMemory[offset:offset+qubits-1]

#     nfloatParamters = circuit.floatParameterLengthMemory[pointers.floatParameterLengthOffset]
#     floatParameter = @view circuit.floatParameterMemory[pointers.floatParameterOffset:pointers.floatParameterOffset+nfloatParamters-1]
#     nintParamters = circuit.intParameterLengthMemory[pointers.intParameterLengthOffset]
#     intParameter = @view circuit.intParameterMemory[pointers.intParameterOffset:pointers.intParameterOffset+nintParamters-1]

#     return ApplyData(type, floatParameter, intParameter, position)
# end

# function _apply_fullyRandom!(circuit::MonitoredQuantumCircuits.Circuit2, i::Int64)
#     pointers = circuit.pointerMemory[i]
#     typeIndex = sample(circuit.typeProbabilityMemory[pointers.typeProbabilityOffset])
#     type = circuit.typeMemory[pointers.typeOffset+typeIndex-1]
#     qubits = circuit.positionLengthMemory[pointers.positionLengthOffset+typeIndex-1]

#     positionIndex = sample(circuit.positionProbabilityMemory[pointers.positionProbabilityOffset+typeIndex-1])

#     offset = pointers.positionOffset
#     options = @view circuit.positionOptionsMemory[pointers.positionOptionsOffset:pointers.positionOptionsOffset+typeIndex-2]
#     nqubits = @view circuit.positionLengthMemory[pointers.positionLengthOffset:pointers.positionLengthOffset+typeIndex-2]
#     offset += LinearAlgebra.dot(options, nqubits)
#     offset += qubits * (positionIndex - 1)
#     position = @view circuit.positionMemory[offset:offset+qubits-1]

#     offset = pointers.floatParameterOffset
#     for j in 1:typeIndex-1
#         offset += circuit.floatParameterLengthMemory[pointers.floatParameterLengthOffset+j]
#     end
#     nfloatParamters = circuit.floatParameterLengthMemory[pointers.floatParameterLengthOffset+typeIndex-1]
#     floatParameter = @view circuit.floatParameterMemory[offset:offset+nfloatParamters-1]

#     offset = pointers.intParameterOffset
#     for j in 1:typeIndex-1
#         offset += circuit.intParameterLengthMemory[pointers.intParameterLengthOffset+j]
#     end
#     nintParamters = circuit.intParameterLengthMemory[pointers.intParameterLengthOffset+typeIndex-1]
#     intParameter = @view circuit.intParameterMemory[offset:offset+nintParamters-1]

#     return ApplyData(type, floatParameter, intParameter, position)
# end

# function dispatch_apply(data::ApplyData, simulator::TableauSimulator, keep_result::Bool)
#     state = simulator.initial_state
#     type = data.type
#     floatParameter = data.floatParameter
#     intParameter = data.intParamter
#     position = data.position

#     if type == 1
#         apply_X!(state, simulator, position[1], keep_result)
#     elseif type == 2
#         apply_Y!(state, simulator, position[1], keep_result)
#     elseif type == 3
#         apply_Z!(state, simulator, position[1], keep_result)
#     elseif type == 4
#         apply_XX!(state, simulator, position[1], position[2], keep_result)
#     elseif type == 5
#         apply_YY!(state, simulator, position[1], position[2], keep_result)
#     elseif type == 6
#         apply_ZZ!(state, simulator, position[1], position[2], keep_result)
#     elseif type == 7
#         apply_NPauli!(state, simulator, intParameter, position, keep_result)
#     end
# end






# function execute(circuit::MonitoredQuantumCircuits.Circuit3,
#     simulator::TableauSimulator; keep_result=false)
#     for i in eachindex(circuit)
#         instruction = circuit.instructions[circuit.pointer[i]]
#         operationIndex = instruction.operationIndecies[StatsBase.sample(instruction.weights)]
#         operationBlock = circuit.operations[operationIndex]
#         position = @view operationBlock.possiblePositions[:, StatsBase.sample(operationBlock.positionWeights)]
#         operation = operationBlock.operation
#         apply!(simulator.initial_state, simulator, operation, position)
#     end
# end
