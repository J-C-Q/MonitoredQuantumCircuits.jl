function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.MZ,
    p::Integer;
    keep_result=true,
    phases=true)

    if keep_result
        _, res = QC.projectZrand!(backend.state, p)
        res = Bool(res/2)
        push!(backend.measurements, res)
        push!(backend.measured_qubits, p)
    else
        QC.projectZ!(backend.state, p; keep_result, phases)
        res = false
    end
    return res
end
