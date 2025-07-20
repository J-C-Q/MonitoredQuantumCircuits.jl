function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.MX,
    p::Integer;
    keep_result=true,
    phases=true)

    if keep_result
        _, res = projectXrand_fast!(backend.state, p, backend.operator)
        res = Bool(res/2)
        push!(backend.measurements, res)
        push!(backend.measured_qubits, p)
    else
        projectX_fast!(backend.state, p, backend.operator; keep_result, phases)
        res = false
    end
    return res
end
