function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.MY,
    p::Integer;
    keep_result=true,
    phases=true)

    if keep_result
        _, res = QC.projectYrand!(backend.state, p)
        res = Bool(res/2)
        push!(backend.measurements, res)
        push!(backend.measured_qubits, p)
    else
        QC.projectY!(backend.state, p; keep_result, phases)
        res = false
    end
    return res
end
