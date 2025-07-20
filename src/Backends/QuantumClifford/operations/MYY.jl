include("./util/fastYY.jl")
function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.MYY,
    p1::Integer,
    p2::Integer;
    keep_result=true,
    phases=true,
    ancilla=aux(backend),  # Default to the number of qubits + ancillas + 1
    kwargs...)

    if keep_result
        _, res = projectYYrand!(backend.state, p1, p2)
        res = Bool(res / 2)
        push!(backend.measurements, res)
        push!(backend.measured_qubits, ancilla)
    else
        projectYY!(backend.state, p1, p2; keep_result, phases)
        res = false
    end
    return res
end

function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.MYY,
    b::MonitoredQuantumCircuits.Bond;
    keep_result=true,
    phases=true,
    ancilla=aux(backend),  # Default to the number of qubits + ancillas + 1
    kwargs...)

    if keep_result
        _, res = projectYYrand!(backend.state, b.qubit1, b.qubit2, backend.operator)
        res = Bool(res / 2)
        push!(backend.measurements, res)
        push!(backend.measured_qubits, ancilla)
    else
        projectYY!(backend.state, b.qubit1, b.qubit2, backend.operator; keep_result, phases)
        res = false
    end
    return res
end
