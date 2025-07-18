include("./util/fastZZ.jl")
function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.ZZ,
    p1::Integer,
    p2::Integer;
    keep_result=true,
    ancilla=aux(backend),  # Default to the number of qubits + ancillas + 1
    kwargs...)

    if keep_result
        _, res = projectZZrand!(backend.state, p1, p2)
        res = Bool(res / 2)
        push!(backend.measurements, res)
        push!(backend.measured_qubits, ancilla)
    else
        projectZZ!(backend.state, p1, p2; keep_result)
        res = false
    end
    return res
end
