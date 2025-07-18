# function apply!(
#     register::QC.Register,
#     ::TableauSimulator,
#     ::MonitoredQuantumCircuits.Measure_Y,
#     p::SubArray)

#     _, res = QC.projectYrand!(register, p[1])
#     push!(register.bits, res / 2)
# end

function MonitoredQuantumCircuits.apply!(
    backend::TableauSimulator,
    ::MonitoredQuantumCircuits.Measure_Y,
    p::Integer;
    keep_result=true)

    if keep_result
        _, res = QC.projectYrand!(backend.state, p)
        res = Bool(res/2)
        push!(backend.measurements, res)
        push!(backend.measured_qubits, p)
    else
        QC.projectY!(backend.state, p; keep_result)
        res = false
    end
    return res
end
