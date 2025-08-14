"""
    TableauSimulator(qubits::Integer; mixed=false, basis=:Z)

A QuantumClifford stabilizer simulator.
"""
struct TableauSimulator <: MonitoredQuantumCircuits.Simulator
    state::QC.MixedDestabilizer{QC.Tableau{Vector{UInt8},Matrix{UInt64}}}
    operator::QC.PauliOperator{Array{UInt8,0},Vector{UInt64}}
    measurements::BitVector
    measured_qubits::Vector{Int64}
    ancillas::Int64
    function TableauSimulator(qubits::Integer; ancillas=0, mixed=true, basis=:Z)
        if mixed
            state = QC.MixedDestabilizer(zero(QC.Stabilizer, qubits))
            operator = QC.zero(QC.PauliOperator, qubits)
            new(state, operator, falses(0), Int64[], ancillas)
        else
            state = QC.MixedDestabilizer(one(QC.Stabilizer, qubits; basis))
            operator = QC.zero(QC.PauliOperator, qubits)
            new(state, operator, falses(0), Int64[], ancillas)
        end
    end
end
function setInitialState!(sim::TableauSimulator, state::QC.MixedDestabilizer)
    sim.state.tab.phases .= state.tab.phases
    sim.state.tab.xzs .= state.tab.xzs
    sim.state.rank = state.rank
end
function aux(backend::TableauSimulator)
    return backend.state.tab.nqubits + backend.ancillas + 1
end

function MonitoredQuantumCircuits.reset!(backend::TableauSimulator; mixed=true, basis=:Z)
    qubits = backend.state.tab.nqubits
    #? maybe this can be done in place
    if mixed
        state = QC.MixedDestabilizer(zero(QC.Stabilizer, qubits))
    else
        state = QC.MixedDestabilizer(one(QC.Stabilizer, qubits; basis))
    end
    setInitialState!(backend, state)
    empty!(backend.measurements)
    empty!(backend.measured_qubits)
    return backend
end

function MonitoredQuantumCircuits.reset!(
    backend::TableauSimulator,
    state::QC.MixedDestabilizer)

    qubits = backend.state.tab.nqubits
    setInitialState!(backend, state)
    empty!(backend.measurements)
    empty!(backend.measured_qubits)
    return backend
end

function Base.show(io::IO, backend::TableauSimulator)
    println(io, "TableauSimulator Backend powerd by QuantumClifford.jl")
    println(io, "Number of qubits: ", backend.state.tab.nqubits)
    println(io, "Number of ancillas: ", backend.ancillas)
    if !isempty(backend.measurements)
        println(io, "Recorded measurements: ", length(backend.measurements))
    else
        println(io, "No measurements recorded.")
    end
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



function MonitoredQuantumCircuits.execute!(simulator::TableauSimulator; kwargs...)
    return simulator
end

function MonitoredQuantumCircuits.execute!(f::F,
    simulator::TableauSimulator, p::P=()->();
    shots=1, kwargs...) where {F<:Function,P<:Function}

    initial_state = simulator.state
    for i in 1:shots
        f()
        p(i)
        MonitoredQuantumCircuits.reset!(simulator, initial_state)
    end

    return simulator
end

function MonitoredQuantumCircuits.get_measurements(backend::TableauSimulator, shot)
    return backend.measurements
end
