include("./util/fastZZ.jl")

function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.MZZ,
    p1::Integer,
    p2::Integer;
    keep_result=true,
    phases=true,
    ancilla=aux(backend),
    kwargs...)

    res = false
    if keep_result
        _, res = projectZZrand!(backend.state, p1, p2,backend.operator)
        res = Bool(res / 2)
        push!(backend.measurements, res)
        push!(backend.measured_qubits, ancilla)
    else
        projectZZ!(backend.state, p1, p2,backend.operator; keep_result,phases)
        res = false
    end
    return res
end

function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.MZZ,
    bond::MonitoredQuantumCircuits.Bond;
    keep_result=true,
    phases=true,
    ancilla=aux(backend),
    kwargs...)

    res = false
    if keep_result
        _, res = projectZZrand!(backend.state, bond.qubit1, bond.qubit2,backend.operator)
        res = Bool(res / 2)
        push!(backend.measurements, res)
        push!(backend.measured_qubits, ancilla)
    else
        projectZZ!(backend.state, bond.qubit1, bond.qubit2,backend.operator; keep_result, phases)
        res = false
    end
    return res
end
